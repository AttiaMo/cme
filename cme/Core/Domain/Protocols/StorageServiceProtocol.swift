import Foundation

protocol StorageServiceProtocol: Sendable {
    func save(_ country: Country) async throws
    func remove(_ country: Country) async throws
    func fetchCountries() async throws -> [Country]
    func clearAll() async throws
}