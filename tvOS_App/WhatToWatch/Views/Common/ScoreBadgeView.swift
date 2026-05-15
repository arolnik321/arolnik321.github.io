import SwiftUI

enum ScoreType {
    case imdb, rtCritics, rtAudience

    var label: String {
        switch self {
        case .imdb: return "IMDb"
        case .rtCritics: return "RT"
        case .rtAudience: return "Aud"
        }
    }

    var color: Color {
        switch self {
        case .imdb: return Color(red: 0.96, green: 0.77, blue: 0.1)
        case .rtCritics: return .red
        case .rtAudience: return Color(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var icon: String {
        switch self {
        case .imdb: return "star.fill"
        case .rtCritics: return "flame.fill"
        case .rtAudience: return "popcorn.fill"
        }
    }
}

struct ScoreBadgeView: View {
    let type: ScoreType
    let value: Int?

    var body: some View {
        if let value {
            HStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.caption2)
                Text("\(value)%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassmorphism(cornerRadius: 8)
        }
    }
}

struct IMDbScoreBadgeView: View {
    let score: Double?

    var body: some View {
        if let score {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                Text(String(format: "%.1f", score))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color(red: 0.96, green: 0.77, blue: 0.1))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassmorphism(cornerRadius: 8)
        }
    }
}
