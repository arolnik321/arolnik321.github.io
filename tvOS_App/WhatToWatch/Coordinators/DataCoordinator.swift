import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class DataCoordinator {
    var trendingMovies: [UnifiedMovie] = []
    var newArrivals: [UnifiedMovie] = []
    var isLoading: Bool = false
    var lastError: NetworkError?

    private let tmdb = TMDBService()
    private let omdb = OMDbService()
    private let watchmode = WatchmodeService()

    var modelContext: ModelContext?

    // MARK: - Public Interface

    func refresh() async {
        await loadTrending()
        await loadNewArrivals()
    }

    func loadTrending() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let dtos = try await tmdb.fetchTrending()
            let movies = await merge(dtos: dtos, isTrending: true, isNewArrival: false)
            trendingMovies = movies
        } catch let error as NetworkError {
            lastError = error
        } catch {
            lastError = .decodingFailure(error)
        }
    }

    func loadNewArrivals() async {
        do {
            let dtos = try await tmdb.fetchNewReleases()
            let movies = await merge(dtos: dtos, isTrending: false, isNewArrival: true)
            newArrivals = movies
        } catch let error as NetworkError {
            lastError = error
        } catch {
            lastError = .decodingFailure(error)
        }
    }

    // Lazily loads streaming providers for a single movie — called on detail navigation
    func loadStreamingSources(for movie: UnifiedMovie) async {
        guard movie.isStreamingDataStale else { return }
        guard let tmdbInt = Int(movie.tmdbID) else { return }
        do {
            let ids = try await watchmode.fetchSources(tmdbID: tmdbInt, tmdbType: movie.mediaType)
            movie.streamingProviderIDs = ids
            movie.streamingLastFetchedAt = Date()
            try? modelContext?.save()
        } catch {
            // Non-fatal: streaming info is nice-to-have
        }
    }

    func movie(for tmdbID: String) -> UnifiedMovie? {
        (trendingMovies + newArrivals).first { $0.tmdbID == tmdbID }
    }

    // MARK: - Merge Logic

    private func merge(dtos: [TMDBMediaDTO], isTrending: Bool, isNewArrival: Bool) async -> [UnifiedMovie] {
        // Reuse persisted models where possible to avoid SwiftData duplicates
        var result: [UnifiedMovie] = []

        for dto in dtos {
            let movie = fetchOrCreate(from: dto, isTrending: isTrending, isNewArrival: isNewArrival)
            result.append(movie)
        }

        // Fan-out OMDb calls with max concurrency 3 to stay within daily budget
        await withTaskGroup(of: (String, OMDbScores)?.self) { group in
            var inFlight = 0
            for movie in result {
                guard let imdbID = movie.imdbID, movie.isMetadataStale else { continue }
                if inFlight >= 3 {
                    if let scored = await group.next() ?? nil {
                        applyScores(scored.1, to: scored.0)
                    }
                    inFlight -= 1
                }
                let tmdbID = movie.tmdbID
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    guard let scores = try? await self.omdb.fetchScores(imdbID: imdbID) else { return nil }
                    return (tmdbID, scores)
                }
                inFlight += 1
            }
            for await scored in group {
                if let scored { applyScores(scored.1, to: scored.0) }
            }
        }

        try? modelContext?.save()
        return result
    }

    private func fetchOrCreate(from dto: TMDBMediaDTO, isTrending: Bool, isNewArrival: Bool) -> UnifiedMovie {
        let tmdbID = String(dto.id)

        // Check in-memory first
        if let existing = movie(for: tmdbID) {
            updateMetadata(existing, from: dto)
            existing.isTrending = isTrending
            existing.isNewArrival = isNewArrival
            return existing
        }

        // Check SwiftData
        if let context = modelContext,
           let persisted = try? context.fetch(FetchDescriptor<UnifiedMovie>(
               predicate: #Predicate { $0.tmdbID == tmdbID }
           )).first {
            updateMetadata(persisted, from: dto)
            persisted.isTrending = isTrending
            persisted.isNewArrival = isNewArrival
            return persisted
        }

        // Create new
        let movie = UnifiedMovie(
            tmdbID: tmdbID,
            title: dto.resolvedTitle,
            mediaType: dto.resolvedMediaType,
            isTrending: isTrending,
            isNewArrival: isNewArrival
        )
        updateMetadata(movie, from: dto)
        modelContext?.insert(movie)
        return movie
    }

    private func updateMetadata(_ movie: UnifiedMovie, from dto: TMDBMediaDTO) {
        movie.title = dto.resolvedTitle
        movie.overview = dto.overview
        movie.tagline = dto.tagline
        movie.posterPath = dto.posterPath
        movie.backdropPath = dto.backdropPath
        movie.tmdbScore = dto.voteAverage
        movie.runtime = dto.runtime
        movie.imdbID = dto.imdbId
        movie.mediaType = dto.resolvedMediaType

        if let genres = dto.genres {
            movie.genres = genres.map { $0.name }
        }

        if let dateStr = dto.resolvedDate {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withFullDate, .withDashSeparatorInDate]
            movie.releaseDate = f.date(from: dateStr)
        }

        movie.lastFetchedAt = Date()
    }

    private func applyScores(_ scores: OMDbScores, to tmdbID: String) {
        guard let movie = movie(for: tmdbID) else { return }
        movie.imdbScore = scores.imdbScore
        movie.rtCriticsScore = scores.rtCriticsScore
        movie.rtAudienceScore = scores.rtAudienceScore
    }
}
