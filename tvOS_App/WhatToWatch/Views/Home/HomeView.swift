import SwiftUI

struct HomeView: View {
    @Environment(DataCoordinator.self) private var coordinator

    // Track scroll position for hero parallax
    @State private var heroScrollOffset: CGFloat = 0

    private var featuredMovie: UnifiedMovie? {
        coordinator.trendingMovies.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let featured = featuredMovie {
                    HeroHeaderView(movie: featured, scrollOffset: heroScrollOffset)
                        .focusSection()
                }

                VStack(spacing: 40) {
                    if !coordinator.trendingMovies.isEmpty {
                        ContentShelfView(
                            title: "Trending Now",
                            movies: coordinator.trendingMovies
                        )
                        .focusSection()
                    }

                    if !coordinator.newArrivals.isEmpty {
                        ContentShelfView(
                            title: "New Arrivals",
                            movies: coordinator.newArrivals
                        )
                        .focusSection()
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 60)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .overlay {
            if coordinator.isLoading && coordinator.trendingMovies.isEmpty {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .task {
            await coordinator.refresh()
        }
    }
}
