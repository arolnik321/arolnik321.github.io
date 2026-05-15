import Foundation

enum StreamingProvider: String, CaseIterable, Identifiable, Codable {
    case netflix = "203"
    case hulu = "157"
    case disneyPlus = "372"
    case max = "1825"
    case appleTVPlus = "371"
    case amazonPrime = "26"
    case peacock = "386"
    case paramountPlus = "444"
    case unknown = "0"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .netflix: return "Netflix"
        case .hulu: return "Hulu"
        case .disneyPlus: return "Disney+"
        case .max: return "Max"
        case .appleTVPlus: return "Apple TV+"
        case .amazonPrime: return "Prime Video"
        case .peacock: return "Peacock"
        case .paramountPlus: return "Paramount+"
        case .unknown: return "Unknown"
        }
    }

    var systemImageName: String {
        switch self {
        case .netflix: return "play.rectangle.fill"
        case .hulu: return "play.circle.fill"
        case .disneyPlus: return "star.fill"
        case .max: return "wand.and.stars"
        case .appleTVPlus: return "appletv.fill"
        case .amazonPrime: return "shippingbox.fill"
        case .peacock: return "bird.fill"
        case .paramountPlus: return "mountain.2.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    static func from(watchmodeID: String) -> StreamingProvider {
        allCases.first { $0.rawValue == watchmodeID } ?? .unknown
    }
}
