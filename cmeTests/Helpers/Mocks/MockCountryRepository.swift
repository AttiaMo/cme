import Foundation
@testable import cme

class MockCountryRepository: CountryRepositoryProtocol {
    var savedCountries: [Country] = []
    var allCountries: [Country] = []
    var shouldThrowError = false
    var errorToThrow: Error?
    var addCountryCallCount = 0
    var removeCountryCallCount = 0
    var fetchAllCountriesCallCount = 0
    var fetchCountryByCodeCallCount = 0
    var searchCountriesCallCount = 0
    var getSavedCountriesCallCount = 0
    
    func fetchAllCountries() async throws -> [Country] {
        fetchAllCountriesCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return allCountries
    }
    
    func fetchCountryByCode(_ code: String) async throws -> Country? {
        fetchCountryByCodeCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return allCountries.first { $0.id.caseInsensitiveCompare(code) == .orderedSame }
    }
    
    func searchCountries(query: String) async throws -> [Country] {
        searchCountriesCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return allCountries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func getSavedCountries() async throws -> [Country] {
        getSavedCountriesCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return savedCountries
    }
    
    func addCountry(_ country: Country) async throws {
        addCountryCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        savedCountries.append(country)
    }
    
    func removeCountry(_ country: Country) async throws {
        removeCountryCallCount += 1
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        savedCountries.removeAll { $0.id == country.id }
    }
}