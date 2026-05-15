import SwiftUI

struct MovieGridView: View {
    let movies: [UnifiedMovie]
    @FocusState private var focusedMovieID: String?

    private let columns = [GridItem(.adaptive(minimum: 220), spacing: 40)]

    var body: some View {
        ScrollView {
            if movies.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(movies, id: \.tmdbID) { movie in
                        NavigationLink(value: movie) {
                            MovieCardView(movie: movie)
                        }
                        .buttonStyle(.card)
                        .focused($focusedMovieID, equals: movie.tmdbID)
                    }
                }
                .padding(60)
            }
        }
        .focusSection()
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.slash")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("No titles found")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 200)
    }
}
