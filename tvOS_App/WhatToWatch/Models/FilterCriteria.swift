import Foundation

enum SortOrder: String, CaseIterable, Identifiable {
    case trending = "Trending"
    case topRated = "Top Rated"
    case newArrivals = "New Arrivals"
    var id: String { rawValue }
}

enum MediaType: String, CaseIterable, Identifiable {
    case all = "All"
    case movies = "Movies"
    case shows = "TV Shows"
    var id: String { rawValue }
}

struct FilterCriteria: Equatable {
    var providers: Set<StreamingProvider> = []
    var sortOrder: SortOrder = .trending
    var mediaType: MediaType = .all

    var isDefault: Bool {
        providers.isEmpty && sortOrder == .trending && mediaType == .all
    }
}
