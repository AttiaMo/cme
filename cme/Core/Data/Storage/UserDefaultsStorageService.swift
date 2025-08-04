import Foundation

actor UserDefaultsStorageService: StorageServiceProtocol {
    private let userDefaults: UserDefaults
    private let storageKey = "com.cme.savedCountries"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(_ country: Country) async throws {
        var countries = try await fetchCountries()
        
        // Check if country already exists
        if !countries.contains(where: { $0.id == country.id }) {
            countries.append(country)
            try await saveCountries(countries)
        }
    }
    
    func remove(_ country: Country) async throws {
        var countries = try await fetchCountries()
        countries.removeAll { $0.id == country.id }
        try await saveCountries(countries)
    }
    
    func fetchCountries() async throws -> [Country] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let countries = try decoder.decode([Country].self, from: data)
            return countries
        } catch {
            throw DomainError.storageError(error)
        }
    }
    
    func clearAll() async throws {
        userDefaults.removeObject(forKey: storageKey)
    }
    
    // MARK: - Private Methods
    
    private func saveCountries(_ countries: [Country]) async throws {
        do {
            let data = try encoder.encode(countries)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            throw DomainError.storageError(error)
        }
    }
}