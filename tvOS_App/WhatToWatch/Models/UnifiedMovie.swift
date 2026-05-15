import Foundation
import SwiftData

@Model
final class UnifiedMovie {
    @Attribute(.unique) var tmdbID: String
    var imdbID: String?
    var title: String
    var overview: String?
    var tagline: String?
    var releaseDate: Date?
    var runtime: Int?
    var mediaType: String  // "movie" or "tv"

    // Stored as comma-separated strings — SwiftData tvOS 17 does not support [String] directly
    var genresRaw: String
    var streamingProviderIDsRaw: String

    var posterPath: String?
    var backdropPath: String?

    var tmdbScore: Double?
    var imdbScore: Double?
    var rtCriticsScore: Int?
    var rtAudienceScore: Int?

    var isTrending: Bool
    var isNewArrival: Bool

    var lastFetchedAt: Date
    var streamingLastFetchedAt: Date?

    init(
        tmdbID: String,
        title: String,
        mediaType: String = "movie",
        isTrending: Bool = false,
        isNewArrival: Bool = false
    ) {
        self.tmdbID = tmdbID
        self.title = title
        self.mediaType = mediaType
        self.genresRaw = ""
        self.streamingProviderIDsRaw = ""
        self.isTrending = isTrending
        self.isNewArrival = isNewArrival
        self.lastFetchedAt = Date()
    }

    var genres: [String] {
        get { genresRaw.isEmpty ? [] : genresRaw.components(separatedBy: ",") }
        set { genresRaw = newValue.joined(separator: ",") }
    }

    var streamingProviderIDs: [String] {
        get { streamingProviderIDsRaw.isEmpty ? [] : streamingProviderIDsRaw.components(separatedBy: ",") }
        set { streamingProviderIDsRaw = newValue.joined(separator: ",") }
    }

    var streamingProviders: [StreamingProvider] {
        streamingProviderIDs.map { StreamingProvider.from(watchmodeID: $0) }.filter { $0 != .unknown }
    }

    func posterURL(size: String = "w500") -> URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }

    func backdropURL(size: String = "w1280") -> URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }

    var isStreamingDataStale: Bool {
        guard let fetched = streamingLastFetchedAt else { return true }
        return Date().timeIntervalSince(fetched) > 86_400  // 24-hour TTL
    }

    var isMetadataStale: Bool {
        Date().timeIntervalSince(lastFetchedAt) > 1_800  // 30-minute TTL
    }
}
