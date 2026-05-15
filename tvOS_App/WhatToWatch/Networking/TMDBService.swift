import Foundation

actor TMDBService {
    private let rateLimiter = RateLimiter(maxRequests: 40, perSeconds: 10)

    // MARK: - Public API

    func fetchTrending(mediaType: String = "all", timeWindow: String = "week") async throws -> [TMDBMediaDTO] {
        let url = try buildURL("/trending/\(mediaType)/\(timeWindow)")
        let response: TMDBPagedResponse = try await fetch(url)
        return response.results
    }

    func fetchNewReleases(page: Int = 1) async throws -> [TMDBMediaDTO] {
        var url = try buildURL("/discover/movie")
        url = url.appending(queryItems: [
            URLQueryItem(name: "sort_by", value: "release_date.desc"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "primary_release_date.lte", value: isoToday()),
            URLQueryItem(name: "primary_release_date.gte", value: isoMonthsAgo(3))
        ])
        let response: TMDBPagedResponse = try await fetch(url)
        return response.results
    }

    func fetchDetails(tmdbID: Int, mediaType: String) async throws -> TMDBMediaDTO {
        let url = try buildURL("/\(mediaType)/\(tmdbID)")
        return try await fetch(url)
    }

    // MARK: - Private Helpers

    private func buildURL(_ path: String, extraItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: APIConfig.tmdbBaseURL + path) else {
            throw NetworkError.invalidURL
        }
        var items = [URLQueryItem(name: "api_key", value: APIConfig.tmdbAPIKey)]
        items.append(contentsOf: extraItems)
        components.queryItems = items
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        try await rateLimiter.waitForToken()
        let (data, response) = try await APIConfig.session.data(from: url)
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 429 { throw NetworkError.rateLimited }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.httpError(statusCode: http.statusCode)
            }
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailure(error)
        }
    }

    private func isoToday() -> String { tmdbDateFormatter().string(from: Date()) }
    private func isoMonthsAgo(_ months: Int) -> String {
        let date = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        return tmdbDateFormatter().string(from: date)
    }

    private func tmdbDateFormatter() -> ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return f
    }
}

// MARK: - DTOs (private to this file)

struct TMDBPagedResponse: Decodable {
    let results: [TMDBMediaDTO]
}

struct TMDBMediaDTO: Decodable {
    let id: Int
    let title: String?          // movies
    let name: String?           // TV shows
    let overview: String?
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?    // movies
    let firstAirDate: String?   // TV shows
    let voteAverage: Double?
    let runtime: Int?
    let genreIds: [Int]?
    let genres: [TMDBGenreDTO]?
    let imdbId: String?
    let mediaType: String?

    var resolvedTitle: String { title ?? name ?? "Unknown" }
    var resolvedDate: String? { releaseDate ?? firstAirDate }
    var resolvedMediaType: String { mediaType ?? (name != nil ? "tv" : "movie") }

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview, tagline, runtime
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
        case genres
        case imdbId = "imdb_id"
        case mediaType = "media_type"
    }
}

struct TMDBGenreDTO: Decodable {
    let id: Int
    let name: String
}

