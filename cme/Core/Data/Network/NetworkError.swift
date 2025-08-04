import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case timeout
    case noInternet
    case serverError(Int)
    case decodingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .timeout:
            return "Request timed out"
        case .noInternet:
            return "No internet connection"
        case .serverError(let code):
            return "Server error (code: \(code))"
        case .decodingFailed:
            return "Failed to parse response"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}