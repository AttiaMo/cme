import Foundation

actor InMemoryStorageService: StorageServiceProtocol {
    private var countries: [Country] = []
    
    func save(_ country: Country) async throws {
        if !countries.contains(where: { $0.id == country.id }) {
            countries.append(country)
        }
    }
    
    func remove(_ country: Country) async throws {
        countries.removeAll { $0.id == country.id }
    }
    
    func fetchCountries() async throws -> [Country] {
        return countries
    }
    
    func clearAll() async throws {
        countries.removeAll()
    }
}