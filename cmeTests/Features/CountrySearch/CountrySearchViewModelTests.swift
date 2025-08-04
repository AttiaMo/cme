import XCTest
@testable import cme

@MainActor
final class CountrySearchViewModelTests: XCTestCase {
    var sut: CountrySearchViewModel!
    var mockRepository: MockCountryRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockCountryRepository()
        sut = CountrySearchViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    func testSearchWithValidQuery() async throws {
        // Given
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
                flagPNGUrl: nil
            ),
            Country(
                id: "GB",
                name: "United Kingdom",
                capital: "London",
                currencies: [Currency(code: "GBP", name: "British Pound", symbol: "£")],
                flagPNGUrl: nil
            )
        ]
        
        // When
        sut.searchText = "United"
        sut.search()
        
        // Wait for debounce and search completion
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then
        XCTAssertEqual(sut.searchResults.count, 2)
        XCTAssertTrue(sut.searchResults.contains { $0.id == "US" })
        XCTAssertTrue(sut.searchResults.contains { $0.id == "GB" })
        XCTAssertFalse(sut.isSearching)
        XCTAssertNil(sut.error)
        XCTAssertEqual(mockRepository.searchCountriesCallCount, 1)
    }
    
    func testSearchWithShortQuery() async throws {
        // Given
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
                flagPNGUrl: nil
            )
        ]
        
        // When
        sut.searchText = "U" // Less than minimum length
        sut.search()
        
        // Wait briefly
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertFalse(sut.isSearching)
        XCTAssertEqual(mockRepository.searchCountriesCallCount, 0)
    }
    
    func testSearchWithEmptyQuery() async throws {
        // Given
        // Set up some initial results by performing a search
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [],
                flagPNGUrl: nil
            )
        ]
        sut.searchText = "United"
        sut.search()
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        XCTAssertFalse(sut.searchResults.isEmpty)
        
        // When
        sut.searchText = "   " // Empty/whitespace
        sut.search()
        
        // Wait briefly
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertFalse(sut.isSearching)
        // First search was performed, second search with empty query should not increment
        XCTAssertEqual(mockRepository.searchCountriesCallCount, 1)
    }
    
    func testSearchDebouncing() async throws {
        // Given
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [],
                flagPNGUrl: nil
            )
        ]
        
        // When - Rapid typing simulation
        sut.searchText = "Uni"
        sut.search()
        
        sut.searchText = "Unit"
        sut.search()
        
        sut.searchText = "United"
        sut.search()
        
        // Wait for debounce
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then - Should only search once with final value
        XCTAssertEqual(mockRepository.searchCountriesCallCount, 1)
        XCTAssertEqual(sut.searchResults.count, 1)
        XCTAssertEqual(sut.searchResults.first?.id, "US")
    }
    
    func testSearchErrorHandling() async throws {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = DomainError.networkError(.noInternet)
        
        // When
        sut.searchText = "Germany"
        sut.search()
        
        // Wait for debounce and search completion
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isSearching)
        
        if case .networkError = sut.error {
            // Success
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func testSearchWithSavedCountriesMarking() async throws {
        // Given
        let usCountry = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [],
            flagPNGUrl: nil
        )
        
        mockRepository.allCountries = [usCountry]
        mockRepository.savedCountries = [usCountry]
        
        // When
        sut.searchText = "United"
        sut.search()
        
        // Wait for debounce and search completion
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then
        XCTAssertEqual(sut.searchResults.count, 1)
        XCTAssertTrue(sut.savedCountryIds.contains("US"))
        XCTAssertEqual(mockRepository.getSavedCountriesCallCount, 1)
    }
    
    func testClearSearch() async throws {
        // Given
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [],
                flagPNGUrl: nil
            )
        ]
        sut.searchText = "United"
        sut.search()
        
        // Wait for search to complete
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        XCTAssertFalse(sut.searchResults.isEmpty)
        
        // When
        sut.clearSearch()
        
        // Then
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertTrue(sut.searchResults.isEmpty)
    }
    
    func testSearchCancellation() async throws {
        // Given
        mockRepository.allCountries = []
        
        // When
        sut.searchText = "Test"
        sut.search()
        
        // Immediately start another search
        sut.searchText = "Different"
        sut.search()
        
        // Wait for debounce
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then - Should only have performed one search with the latest query
        XCTAssertEqual(mockRepository.searchCountriesCallCount, 1)
    }
    
    func testErrorClearingOnNewSearch() async throws {
        // Given - Set up error state
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = DomainError.networkError(.noInternet)
        
        sut.searchText = "Test"
        sut.search()
        
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.showError)
        
        // When - Perform new search with success
        mockRepository.shouldThrowError = false
        mockRepository.allCountries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [],
                flagPNGUrl: nil
            )
        ]
        
        sut.searchText = "United"
        sut.search()
        
        // Immediately after starting search, error should be cleared
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.showError)
        
        try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime + 100_000_000)
        
        // Then
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.showError)
        XCTAssertEqual(sut.searchResults.count, 1)
    }
}