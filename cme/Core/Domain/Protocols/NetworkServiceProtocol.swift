import Foundation

protocol NetworkServiceProtocol: Sendable {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
}