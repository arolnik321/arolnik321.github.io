import Foundation

actor WatchmodeService {
    // 1000 req/month free tier — only called lazily on detail navigation, results cached 24h
    private let rateLimiter = RateLimiter(maxRequests: 1, perSeconds: 3)

    func fetchSources(tmdbID: Int, tmdbType: String) async throws -> [String] {
        // Watchmode requires resolving TMDB → Watchmode title ID first, then fetching sources
        let titleID = try await resolveTitleID(tmdbID: tmdbID, tmdbType: tmdbType)
        return try await fetchSourceIDs(titleID: titleID)
    }

    // MARK: - Private

    private func resolveTitleID(tmdbID: Int, tmdbType: String) async throws -> Int {
        guard var components = URLComponents(string: "\(APIConfig.watchmodeBaseURL)/search/") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: APIConfig.watchmodeAPIKey),
            URLQueryItem(name: "search_field", value: "tmdb_movie_id"),
            URLQueryItem(name: "search_value", value: "\(tmdbID)")
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }

        try await rateLimiter.waitForToken()
        let (data, response) = try await APIConfig.session.data(from: url)
        try validateHTTP(response)

        let result: WatchmodeSearchResponse
        do {
            result = try JSONDecoder().decode(WatchmodeSearchResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailure(error)
        }

        guard let titleID = result.titleResults.first?.id else {
            throw NetworkError.noData
        }
        return titleID
    }

    private func fetchSourceIDs(titleID: Int) async throws -> [String] {
        guard var components = URLComponents(string: "\(APIConfig.watchmodeBaseURL)/title/\(titleID)/sources/") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: APIConfig.watchmodeAPIKey),
            URLQueryItem(name: "regions", value: "US")
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }

        try await rateLimiter.waitForToken()
        let (data, response) = try await APIConfig.session.data(from: url)
        try validateHTTP(response)

        let sources: [WatchmodeSourceDTO]
        do {
            sources = try JSONDecoder().decode([WatchmodeSourceDTO].self, from: data)
        } catch {
            throw NetworkError.decodingFailure(error)
        }

        // Return unique source IDs for subscription/free streaming only
        let subscriptionTypes = ["sub", "free"]
        return Array(Set(sources
            .filter { subscriptionTypes.contains($0.type) }
            .map { String($0.sourceID) }
        ))
    }

    private func validateHTTP(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 429 { throw NetworkError.rateLimited }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
    }
}

// MARK: - DTOs

private struct WatchmodeSearchResponse: Decodable {
    let titleResults: [WatchmodeTitleResult]
    enum CodingKeys: String, CodingKey {
        case titleResults = "title_results"
    }
}

private struct WatchmodeTitleResult: Decodable {
    let id: Int
}

private struct WatchmodeSourceDTO: Decodable {
    let sourceID: Int
    let type: String
    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case type
    }
}
