import SwiftUI
import SwiftData

struct MovieDetailView: View {
    let movie: UnifiedMovie
    @Environment(DataCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var savedItems: [WantToWatchItem]
    @Namespace private var focusScope

    private var isSaved: Bool {
        savedItems.contains { $0.tmdbID == movie.tmdbID }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backdropBackground
            gradientOverlay
            contentLayer
        }
        .ignoresSafeArea()
        .onExitCommand { dismiss() }
        .task {
            await coordinator.loadStreamingSources(for: movie)
        }
    }

    private var backdropBackground: some View {
        AsyncImage(url: movie.backdropURL(size: "original")) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            default:
                Color.black
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black.opacity(0.7), location: 0.4),
                .init(color: .black, location: 0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text(movie.title)
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.white)

            metaRow

            if let overview = movie.overview {
                Text(overview)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(4)
                    .frame(maxWidth: 900, alignment: .leading)
            }

            if !movie.streamingProviders.isEmpty {
                PlatformBadgeStripView(providers: movie.streamingProviders)
            }

            actionButtons
        }
        .padding(.horizontal, 60)
        .padding(.bottom, 80)
        .focusScope(focusScope)
    }

    private var metaRow: some View {
        HStack(spacing: 16) {
            if let year = movie.releaseDate.map({ Calendar.current.component(.year, from: $0) }) {
                Text(String(year))
                    .foregroundStyle(.secondary)
            }
            if let runtime = movie.runtime {
                Text("\(runtime) min")
                    .foregroundStyle(.secondary)
            }
            if !movie.genres.isEmpty {
                Text(movie.genres.prefix(3).joined(separator: " · "))
                    .foregroundStyle(.secondary)
            }
            IMDbScoreBadgeView(score: movie.imdbScore)
            ScoreBadgeView(type: .rtCritics, value: movie.rtCriticsScore)
        }
        .font(.title3)
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button {
                toggleWantToWatch()
            } label: {
                Label(
                    isSaved ? "Saved" : "Add to My List",
                    systemImage: isSaved ? "bookmark.fill" : "bookmark"
                )
                .font(.title3)
                .frame(minWidth: 240, minHeight: 80)
            }
            .buttonStyle(.card)
            .prefersDefaultFocus(in: focusScope)
        }
    }

    private func toggleWantToWatch() {
        if let existing = savedItems.first(where: { $0.tmdbID == movie.tmdbID }) {
            modelContext.delete(existing)
        } else {
            let item = WantToWatchItem(
                tmdbID: movie.tmdbID,
                title: movie.title,
                posterPath: movie.posterPath
            )
            modelContext.insert(item)
        }
        try? modelContext.save()
    }
}
