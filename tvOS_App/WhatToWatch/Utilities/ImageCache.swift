import Foundation

// URLCache-backed caching is configured in APIConfig.session.
// This actor provides an in-memory layer for decoded image data to avoid redundant disk reads.
actor ImageCache {
    static let shared = ImageCache()
    private var cache: [URL: Data] = [:]

    func data(for url: URL) -> Data? {
        cache[url]
    }

    func store(_ data: Data, for url: URL) {
        cache[url] = data
    }
}
