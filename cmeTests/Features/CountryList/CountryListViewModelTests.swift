import XCTest
@testable import cme

@MainActor
final class CountryListViewModelTests: XCTestCase {
    var sut: CountryListViewModel!
    var mockRepository: MockCountryRepository!
    var mockLocationService: MockLocationService!
    var locationBootstrap: LocationBootstrapUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockCountryRepository()
        mockLocationService = MockLocationService()
        locationBootstrap = LocationBootstrapUseCase(
            locationService: mockLocationService,
            repository: mockRepository,
            defaultCountryCode: "DE"
        )
        sut = CountryListViewModel(
            repository: mockRepository,
            locationBootstrap: locationBootstrap
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        mockLocationService = nil
        locationBootstrap = nil
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
        // Set up mock repository to return Germany when looking for "DE"
        mockRepository.allCountries = [
            Country(
                id: "DE",
                name: "Germany",
                capital: "Berlin",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: nil
            )
        ]
        mockLocationService.mockCountryCode = "DE"
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertEqual(sut.countries.count, 1)
        XCTAssertEqual(sut.countries.first?.id, "DE")
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