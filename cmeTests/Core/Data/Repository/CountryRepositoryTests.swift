import XCTest
@testable import cme

final class CountryRepositoryTests: XCTestCase {
    var sut: CountryRepository!
    var mockNetworkService: MockNetworkService!
    var mockStorageService: MockStorageService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockNetworkService = MockNetworkService()
        mockStorageService = MockStorageService()
        sut = CountryRepository(
            networkService: mockNetworkService,
            storageService: mockStorageService
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockNetworkService = nil
        mockStorageService = nil
        try await super.tearDown()
    }
    
    func testAddCountrySuccess() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        mockStorageService.countries = []
        
        // When
        try await sut.addCountry(country)
        
        // Then
        XCTAssertEqual(mockStorageService.saveCallCount, 1)
        XCTAssertEqual(mockStorageService.countries.count, 1)
        XCTAssertEqual(mockStorageService.countries.first?.id, "US")
    }
    
    func testAddCountryMaxLimitReached() async throws {
        // Given
        let existingCountries = (0..<5).map { index in
            Country(
                id: "C\(index)",
                name: "Country \(index)",
                capital: "Capital \(index)",
                currencies: [Currency(code: "CUR\(index)", name: "Currency \(index)", symbol: "$")],
                flagPNGUrl: nil
            )
        }
        mockStorageService.countries = existingCountries
        
        let newCountry = Country(
            id: "NEW",
            name: "New Country",
            capital: "New Capital",
            currencies: [Currency(code: "NEW", name: "New Currency", symbol: "$")],
            flagPNGUrl: nil
        )
        
        // When & Then
        do {
            try await sut.addCountry(newCountry)
            XCTFail("Should throw maxCountriesReached error")
        } catch let error as DomainError {
            if case .maxCountriesReached(let limit) = error {
                XCTAssertEqual(limit, 5)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testAddDuplicateCountry() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        mockStorageService.countries = [country]
        
        // When & Then
        do {
            try await sut.addCountry(country)
            XCTFail("Should throw duplicateCountry error")
        } catch let error as DomainError {
            if case .duplicateCountry(let name) = error {
                XCTAssertEqual(name, "United States")
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testSearchCountriesSuccess() async throws {
        // Given
        let countryDTOs = [
            CountryDTO(
                name: "Germany",
                capital: "Berlin",
                currencies: [CurrencyDTO(code: "EUR", name: "Euro", symbol: "€")],
                alpha2Code: "DE",
                flags: FlagsDTO(svg: nil, png: "https://flagcdn.com/w320/de.png")
            )
        ]
        mockNetworkService.mockResponse = countryDTOs
        
        // When
        let results = try await sut.searchCountries(query: "Germany")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
        XCTAssertEqual(results.first?.id, "DE")
    }
    
    func testSearchCountriesEmptyQuery() async throws {
        // When
        let results = try await sut.searchCountries(query: "   ")
        
        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(mockNetworkService.fetchCallCount, 0)
    }
}