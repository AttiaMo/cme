import XCTest
@testable import cme

final class LocationBootstrapUseCaseTests: XCTestCase {
    var sut: LocationBootstrapUseCase!
    var mockLocationService: MockLocationService!
    var mockRepository: MockCountryRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockLocationService = MockLocationService()
        mockRepository = MockCountryRepository()
        sut = LocationBootstrapUseCase(
            locationService: mockLocationService,
            repository: mockRepository,
            defaultCountryCode: "DE"
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockLocationService = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    func testBootstrapSuccessWithLocationService() async throws {
        // Given
        mockLocationService.mockCountryCode = "US"
        mockRepository.allCountries = [
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
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "US")
        XCTAssertEqual(result?.name, "United States")
        XCTAssertEqual(mockLocationService.getCurrentCountryCodeCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCountryByCodeCallCount, 1)
    }
    
    func testBootstrapFallbackToDefaultOnLocationError() async throws {
        // Given
        mockLocationService.shouldThrowError = true
        mockLocationService.errorToThrow = DomainError.locationDenied
        mockRepository.allCountries = [
            Country(
                id: "DE",
                name: "Germany",
                capital: "Berlin",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: nil
            )
        ]
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "DE")
        XCTAssertEqual(result?.name, "Germany")
        XCTAssertEqual(mockLocationService.getCurrentCountryCodeCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCountryByCodeCallCount, 1)
    }
    
    func testBootstrapFallbackToDefaultOnLocationUnavailable() async throws {
        // Given
        mockLocationService.shouldThrowError = true
        mockLocationService.errorToThrow = DomainError.locationUnavailable
        mockRepository.allCountries = [
            Country(
                id: "DE",
                name: "Germany",
                capital: "Berlin",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: nil
            )
        ]
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "DE")
        XCTAssertEqual(mockLocationService.getCurrentCountryCodeCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCountryByCodeCallCount, 1)
    }
    
    func testBootstrapReturnsNilWhenCountryNotFound() async throws {
        // Given
        mockLocationService.mockCountryCode = "XX" // Non-existent country
        mockRepository.allCountries = []
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNil(result)
        XCTAssertEqual(mockLocationService.getCurrentCountryCodeCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCountryByCodeCallCount, 1)
    }
    
    func testBootstrapReturnsNilWhenDefaultCountryNotFound() async throws {
        // Given
        mockLocationService.shouldThrowError = true
        mockRepository.allCountries = [] // No countries available
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNil(result)
        XCTAssertEqual(mockLocationService.getCurrentCountryCodeCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCountryByCodeCallCount, 1)
    }
    
    func testBootstrapWithCustomDefaultCountry() async throws {
        // Given
        let customDefault = "FR"
        let customSut = LocationBootstrapUseCase(
            locationService: mockLocationService,
            repository: mockRepository,
            defaultCountryCode: customDefault
        )
        
        mockLocationService.shouldThrowError = true
        mockRepository.allCountries = [
            Country(
                id: "FR",
                name: "France",
                capital: "Paris",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: nil
            )
        ]
        
        // When
        let result = try await customSut.bootstrap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "FR")
        XCTAssertEqual(result?.name, "France")
    }
    
    func testBootstrapHandlesCaseInsensitiveCountryCode() async throws {
        // Given
        mockLocationService.mockCountryCode = "us" // lowercase
        mockRepository.allCountries = [
            Country(
                id: "US", // uppercase in repository
                name: "United States",
                capital: "Washington D.C.",
                currencies: [],
                flagPNGUrl: nil
            )
        ]
        
        // When
        let result = try await sut.bootstrap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "US")
    }
}