import Foundation
import SwiftData

// Deliberately decoupled from UnifiedMovie so it maps to a flat Supabase row with no joins.
@Model
final class WantToWatchItem {
    @Attribute(.unique) var id: UUID
    var tmdbID: String
    var title: String
    var posterPath: String?
    var addedAt: Date
    var notes: String?

    init(tmdbID: String, title: String, posterPath: String? = nil) {
        self.id = UUID()
        self.tmdbID = tmdbID
        self.title = title
        self.posterPath = posterPath
        self.addedAt = Date()
    }

    func posterURL(size: String = "w500") -> URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }
}
