import Foundation

protocol LocationServiceProtocol: Sendable {
    func getCurrentCountryCode() async throws -> String
}