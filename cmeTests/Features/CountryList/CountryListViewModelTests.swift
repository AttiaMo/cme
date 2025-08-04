import XCTest
@testable import cme

@MainActor
final class CountryListViewModelTests: XCTestCase {
    var sut: CountryListViewModel!
    var mockRepository: MockCountryRepository!
    var mockLocationBootstrap: MockLocationBootstrapUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockCountryRepository()
        mockLocationBootstrap = MockLocationBootstrapUseCase()
        sut = CountryListViewModel(
            repository: mockRepository,
            locationBootstrap: mockLocationBootstrap
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        mockLocationBootstrap = nil
        try await super.tearDown()
    }
    
    func testLoadCountriesSuccess() async throws {
        // Given
        let countries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
                flagPNGUrl: nil
            ),
            Country(
                id: "DE",
                name: "Germany",
                capital: "Berlin",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: nil
            )
        ]
        mockRepository.savedCountries = countries
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertEqual(sut.countries.count, 2)
        XCTAssertEqual(sut.countries.first?.id, "US")
        XCTAssertEqual(sut.countries.last?.id, "DE")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testLoadCountriesWithBootstrap() async throws {
        // Given
        mockRepository.savedCountries = []
        let bootstrapCountry = Country(
            id: "DE",
            name: "Germany",
            capital: "Berlin",
            currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
            flagPNGUrl: nil
        )
        mockLocationBootstrap.bootstrapCountry = bootstrapCountry
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertEqual(sut.countries.count, 1)
        XCTAssertEqual(sut.countries.first?.id, "DE")
        XCTAssertTrue(mockLocationBootstrap.bootstrapCalled)
        XCTAssertEqual(mockRepository.addCountryCallCount, 1)
    }
    
    func testAddCountrySuccess() async throws {
        // Given
        mockRepository.savedCountries = []
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        
        // When
        await sut.addCountry(country)
        
        // Then
        XCTAssertEqual(mockRepository.addCountryCallCount, 1)
        XCTAssertTrue(mockRepository.savedCountries.contains { $0.id == "US" })
    }
    
    func testRemoveCountrySuccess() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        mockRepository.savedCountries = [country]
        
        // When
        await sut.loadCountries() // Load initial countries
        await sut.removeCountry(country)
        
        // Then
        XCTAssertEqual(mockRepository.removeCountryCallCount, 1)
        XCTAssertTrue(sut.countries.isEmpty)
    }
    
    func testErrorHandling() async throws {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = DomainError.networkError(.noInternet)
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.showError)
        if case .networkError = sut.error {
            // Success
        } else {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Mock Classes

class MockCountryRepository: CountryRepositoryProtocol {
    var savedCountries: [Country] = []
    var allCountries: [Country] = []
    var shouldThrowError = false
    var errorToThrow: Error?
    var addCountryCallCount = 0
    var removeCountryCallCount = 0
    
    func fetchAllCountries() async throws -> [Country] {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return allCountries
    }
    
    func searchCountries(query: String) async throws -> [Country] {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return allCountries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func getSavedCountries() async throws -> [Country] {
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

@MainActor
class MockLocationBootstrapUseCase: Sendable {
    var bootstrapCountry: Country?
    var bootstrapCalled = false
    
    func bootstrap() async throws -> Country? {
        bootstrapCalled = true
        return bootstrapCountry
    }
}