import Foundation

enum APIConfig {
    nonisolated(unsafe) static let tmdbAPIKey: String = {
        guard let v = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String, !v.isEmpty else {
            fatalError("Missing TMDB_API_KEY in Info.plist — see SETUP.md")
        }
        return v
    }()

    nonisolated(unsafe) static let omdbAPIKey: String = {
        guard let v = Bundle.main.infoDictionary?["OMDB_API_KEY"] as? String, !v.isEmpty else {
            fatalError("Missing OMDB_API_KEY in Info.plist — see SETUP.md")
        }
        return v
    }()

    nonisolated(unsafe) static let watchmodeAPIKey: String = {
        guard let v = Bundle.main.infoDictionary?["WATCHMODE_API_KEY"] as? String, !v.isEmpty else {
            fatalError("Missing WATCHMODE_API_KEY in Info.plist — see SETUP.md")
        }
        return v
    }()

    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let omdbBaseURL = "https://www.omdbapi.com"
    static let watchmodeBaseURL = "https://api.watchmode.com/v1"
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p"

    nonisolated(unsafe) static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 512 * 1024 * 1024)
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
}
