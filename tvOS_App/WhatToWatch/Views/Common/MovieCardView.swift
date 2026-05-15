import SwiftUI

struct MovieCardView: View {
    let movie: UnifiedMovie
    // Card is always inside a .buttonStyle(.card) Button, so isFocused comes from environment
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            posterImage
                .overlay(alignment: .topTrailing) {
                    IMDbScoreBadgeView(score: movie.imdbScore)
                        .padding(8)
                        .opacity(isFocused ? 1 : 0)
                }
                .overlay(alignment: .bottom) {
                    if isFocused && !movie.streamingProviders.isEmpty {
                        PlatformBadgeStripView(providers: movie.streamingProviders)
                            .padding(8)
                    }
                }

            Text(movie.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(width: 200, alignment: .leading)
        }
        .scaleEffect(isFocused ? 1.2 : 1.0)
        .shadow(
            color: .black.opacity(isFocused ? 0.4 : 0),
            radius: isFocused ? 30 : 0,
            y: isFocused ? 12 : 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    private var posterImage: some View {
        AsyncImage(url: movie.posterURL()) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure, .empty:
                posterPlaceholder
            @unknown default:
                posterPlaceholder
            }
        }
        .frame(width: 200, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            )
    }
}
