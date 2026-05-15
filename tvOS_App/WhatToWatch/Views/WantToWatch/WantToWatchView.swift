import SwiftUI
import SwiftData

struct WantToWatchView: View {
    @Query(sort: \WantToWatchItem.addedAt, order: .reverse) private var items: [WantToWatchItem]
    @Environment(\.modelContext) private var modelContext
    @Environment(DataCoordinator.self) private var coordinator

    @State private var itemToDelete: WantToWatchItem?
    @State private var showDeleteConfirm = false

    var body: some View {
        Group {
            if items.isEmpty {
                emptyState
            } else {
                savedGrid
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onExitCommand {}
        .confirmationDialog("Remove from My List?", isPresented: $showDeleteConfirm, presenting: itemToDelete) { item in
            Button("Remove \"\(item.title)\"", role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }

    private var savedGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 40)], spacing: 40) {
                ForEach(items) { item in
                    savedCard(for: item)
                }
            }
            .padding(60)
        }
        .focusSection()
    }

    private func savedCard(for item: WantToWatchItem) -> some View {
        let movie = coordinator.movie(for: item.tmdbID)
        return Group {
            if let movie {
                NavigationLink(value: movie) {
                    MovieCardView(movie: movie)
                }
                .buttonStyle(.card)
                .contextMenu {
                    Button("Remove", role: .destructive) {
                        itemToDelete = item
                        showDeleteConfirm = true
                    }
                }
            } else {
                // Render from WantToWatchItem when movie isn't in coordinator cache
                savedItemFallbackCard(item: item)
            }
        }
    }

    private func savedItemFallbackCard(item: WantToWatchItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: item.posterURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 200, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.title)
                .font(.title3)
                .lineLimit(2)
                .frame(width: 200, alignment: .leading)
        }
        .contextMenu {
            Button("Remove", role: .destructive) {
                itemToDelete = item
                showDeleteConfirm = true
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("Your list is empty")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Add titles from the Home or Browse tabs")
                .font(.title3)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
