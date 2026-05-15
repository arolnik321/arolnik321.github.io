import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailure(Error)
    case httpError(statusCode: Int)
    case rateLimited
    case apiKeyMissing(service: String)

    var isRetryable: Bool {
        switch self {
        case .httpError(let code): return code == 429 || (500...599).contains(code)
        case .rateLimited: return true
        default: return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingFailure(let error): return "Decoding failed: \(error.localizedDescription)"
        case .httpError(let code): return "HTTP error \(code)"
        case .rateLimited: return "Rate limit exceeded"
        case .apiKeyMissing(let service): return "API key missing for \(service)"
        }
    }
}
