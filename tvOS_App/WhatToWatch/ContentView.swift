import SwiftUI

enum Tab: Hashable {
    case home, browse, myList
}

struct ContentView: View {
    @State private var coordinator = DataCoordinator()
    @State private var selectedTab: Tab = .home
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)

                BrowseView()
                    .tabItem { Label("Browse", systemImage: "square.grid.2x2") }
                    .tag(Tab.browse)

                WantToWatchView()
                    .tabItem { Label("My List", systemImage: "bookmark.fill") }
                    .tag(Tab.myList)
            }
            .tabViewStyle(.sidebarAdaptable)
            .navigationDestination(for: UnifiedMovie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .environment(coordinator)
        .task {
            coordinator.modelContext = try? ModelContext(ModelContainer(for: UnifiedMovie.self, WantToWatchItem.self))
        }
    }
}
