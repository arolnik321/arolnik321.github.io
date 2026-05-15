import Foundation

actor OMDbService {
    // 1000 req/day → ~1 per 87 seconds. We use max concurrency of 3 at call site instead of per-call sleeping.
    private let rateLimiter = RateLimiter(maxRequests: 10, perSeconds: 60)

    func fetchScores(imdbID: String) async throws -> OMDbScores {
        guard var components = URLComponents(string: APIConfig.omdbBaseURL) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "i", value: imdbID),
            URLQueryItem(name: "apikey", value: APIConfig.omdbAPIKey)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }

        try await rateLimiter.waitForToken()
        let (data, response) = try await APIConfig.session.data(from: url)
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 429 { throw NetworkError.rateLimited }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.httpError(statusCode: http.statusCode)
            }
        }

        let dto: OMDbResponseDTO
        do {
            dto = try JSONDecoder().decode(OMDbResponseDTO.self, from: data)
        } catch {
            throw NetworkError.decodingFailure(error)
        }

        return OMDbScores(
            imdbScore: Double(dto.imdbRating ?? ""),
            rtCriticsScore: dto.ratings?.first(where: { $0.source == "Rotten Tomatoes" }).flatMap {
                Int($0.value.replacingOccurrences(of: "%", with: ""))
            },
            rtAudienceScore: dto.ratings?.first(where: { $0.source == "Metacritic" }).flatMap {
                Int($0.value.components(separatedBy: "/").first ?? "")
            }
        )
    }
}

// MARK: - DTOs

private struct OMDbResponseDTO: Decodable {
    let imdbRating: String?
    let ratings: [OMDbRatingDTO]?

    enum CodingKeys: String, CodingKey {
        case imdbRating = "imdbRating"
        case ratings = "Ratings"
    }
}

private struct OMDbRatingDTO: Decodable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}

// MARK: - Result type

struct OMDbScores {
    let imdbScore: Double?
    let rtCriticsScore: Int?
    let rtAudienceScore: Int?
}
