import SwiftUI

struct BrowseView: View {
    @Environment(DataCoordinator.self) private var coordinator
    @State private var criteria = FilterCriteria()

    private var allMovies: [UnifiedMovie] {
        Array(Set(coordinator.trendingMovies + coordinator.newArrivals)
            .sorted { ($0.tmdbScore ?? 0) > ($1.tmdbScore ?? 0) })
    }

    private var filteredMovies: [UnifiedMovie] {
        var movies = allMovies

        // Provider filter
        if !criteria.providers.isEmpty {
            let targetIDs = Set(criteria.providers.map { $0.rawValue })
            movies = movies.filter { !Set($0.streamingProviderIDs).isDisjoint(with: targetIDs) }
        }

        // Media type filter
        switch criteria.mediaType {
        case .movies: movies = movies.filter { $0.mediaType == "movie" }
        case .shows: movies = movies.filter { $0.mediaType == "tv" }
        case .all: break
        }

        // Sort
        switch criteria.sortOrder {
        case .trending: movies = movies.filter { $0.isTrending }
        case .topRated: movies = movies.sorted { ($0.rtCriticsScore ?? 0) > ($1.rtCriticsScore ?? 0) }
        case .newArrivals: movies = movies.filter { $0.isNewArrival }
        }

        return movies
    }

    var body: some View {
        VStack(spacing: 0) {
            FilterBarView(criteria: $criteria)
                .focusSection()

            MovieGridView(movies: filteredMovies)
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            if coordinator.trendingMovies.isEmpty {
                await coordinator.refresh()
            }
        }
    }
}
