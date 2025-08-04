import Foundation
@testable import cme

class MockStorageService: StorageServiceProtocol {
    var countries: [Country] = []
    var saveCallCount = 0
    var removeCallCount = 0
    var fetchCallCount = 0
    var clearAllCallCount = 0
    var shouldThrowError = false
    var errorToThrow: Error?
    
    func save(_ country: Country) async throws {
        saveCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        if !countries.contains(where: { $0.id == country.id }) {
            countries.append(country)
        }
    }
    
    func remove(_ country: Country) async throws {
        removeCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        countries.removeAll { $0.id == country.id }
    }
    
    func fetchCountries() async throws -> [Country] {
        fetchCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return countries
    }
    
    func clearAll() async throws {
        clearAllCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        countries.removeAll()
    }
}