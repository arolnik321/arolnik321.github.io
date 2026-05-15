import SwiftUI

struct HeroHeaderView: View {
    let movie: UnifiedMovie
    @Environment(\.dismiss) private var dismiss
    @Namespace private var focusScope

    // Scroll offset passed in from parent GeometryReader for parallax
    var scrollOffset: CGFloat = 0

    private var parallaxAngle: Double {
        // Clamp to ±5° to prevent motion sickness on a 10-foot display
        let raw = Double(scrollOffset) * 0.01
        return max(-5, min(5, raw))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backdropLayer
            gradientOverlay
            contentLayer
        }
        .frame(maxWidth: .infinity)
        .frame(height: 800)
        .clipped()
        .onExitCommand { dismiss() }
    }

    private var backdropLayer: some View {
        AsyncImage(url: movie.backdropURL()) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            default:
                Rectangle().fill(Color.black.opacity(0.8))
            }
        }
        .ignoresSafeArea()
        .rotation3DEffect(
            .degrees(parallaxAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 1500
        )
        .animation(.interactiveSpring(), value: scrollOffset)
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black.opacity(0.6), location: 0.5),
                .init(color: .black, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(movie.title)
                .font(.system(size: 76, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .shadow(radius: 4)

            if let tagline = movie.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }

            scoresRow

            if !movie.streamingProviders.isEmpty {
                PlatformBadgeStripView(providers: movie.streamingProviders)
            }

            actionButtons
        }
        .padding(.horizontal, 60)
        .padding(.bottom, 60)
        .focusScope(focusScope)
    }

    private var scoresRow: some View {
        HStack(spacing: 12) {
            IMDbScoreBadgeView(score: movie.imdbScore)
            ScoreBadgeView(type: .rtCritics, value: movie.rtCriticsScore)
            ScoreBadgeView(type: .rtAudience, value: movie.rtAudienceScore)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button {
                // Play action handled by parent via NavigationLink
            } label: {
                Label("More Info", systemImage: "info.circle")
                    .font(.title3)
                    .frame(minWidth: 200, minHeight: 80)
            }
            .buttonStyle(.card)
            .prefersDefaultFocus(in: focusScope)
        }
    }
}
