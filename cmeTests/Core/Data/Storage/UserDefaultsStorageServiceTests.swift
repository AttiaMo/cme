import XCTest
@testable import cme

final class UserDefaultsStorageServiceTests: XCTestCase {
    var sut: UserDefaultsStorageService!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "com.cme.tests")
        mockUserDefaults.removePersistentDomain(forName: "com.cme.tests")
        sut = UserDefaultsStorageService(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() async throws {
        mockUserDefaults.removePersistentDomain(forName: "com.cme.tests")
        mockUserDefaults = nil
        sut = nil
        try await super.tearDown()
    }
    
    func testSaveCountry() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        
        // When
        try await sut.save(country)
        
        // Then
        let savedCountries = try await sut.fetchCountries()
        XCTAssertEqual(savedCountries.count, 1)
        XCTAssertEqual(savedCountries.first?.id, "US")
        XCTAssertEqual(savedCountries.first?.name, "United States")
    }
    
    func testSaveDuplicateCountry() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        
        // When
        try await sut.save(country)
        try await sut.save(country) // Save same country again
        
        // Then
        let savedCountries = try await sut.fetchCountries()
        XCTAssertEqual(savedCountries.count, 1) // Should not duplicate
    }
    
    func testRemoveCountry() async throws {
        // Given
        let country1 = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        let country2 = Country(
            id: "DE",
            name: "Germany",
            capital: "Berlin",
            currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
            flagPNGUrl: nil
        )
        
        try await sut.save(country1)
        try await sut.save(country2)
        
        // When
        try await sut.remove(country1)
        
        // Then
        let savedCountries = try await sut.fetchCountries()
        XCTAssertEqual(savedCountries.count, 1)
        XCTAssertEqual(savedCountries.first?.id, "DE")
    }
    
    func testFetchEmptyCountries() async throws {
        // When
        let countries = try await sut.fetchCountries()
        
        // Then
        XCTAssertTrue(countries.isEmpty)
    }
    
    func testClearAll() async throws {
        // Given
        let country1 = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        let country2 = Country(
            id: "DE",
            name: "Germany",
            capital: "Berlin",
            currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
            flagPNGUrl: nil
        )
        
        try await sut.save(country1)
        try await sut.save(country2)
        
        // When
        try await sut.clearAll()
        
        // Then
        let savedCountries = try await sut.fetchCountries()
        XCTAssertTrue(savedCountries.isEmpty)
    }
    
    func testPersistenceAcrossInstances() async throws {
        // Given
        let country = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: nil
        )
        
        // When
        try await sut.save(country)
        
        // Create new instance with same UserDefaults
        let newSut = UserDefaultsStorageService(userDefaults: mockUserDefaults)
        
        // Then
        let savedCountries = try await newSut.fetchCountries()
        XCTAssertEqual(savedCountries.count, 1)
        XCTAssertEqual(savedCountries.first?.id, "US")
    }
    
    func testMultipleCountriesPersistence() async throws {
        // Given
        let countries = [
            Country(
                id: "US",
                name: "United States",
                capital: "Washington D.C.",
                currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
                flagPNGUrl: URL(string: "https://flagcdn.com/w320/us.png")
            ),
            Country(
                id: "DE",
                name: "Germany",
                capital: "Berlin",
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flagPNGUrl: URL(string: "https://flagcdn.com/w320/de.png")
            ),
            Country(
                id: "JP",
                name: "Japan",
                capital: "Tokyo",
                currencies: [Currency(code: "JPY", name: "Japanese Yen", symbol: "¥")],
                flagPNGUrl: URL(string: "https://flagcdn.com/w320/jp.png")
            )
        ]
        
        // When - Save all countries
        for country in countries {
            try await sut.save(country)
        }
        
        // Then - Verify immediate persistence
        let savedCountries = try await sut.fetchCountries()
        XCTAssertEqual(savedCountries.count, 3)
        
        // When - Create new instance (simulating app restart)
        sut = nil // Release current instance
        let newSut = UserDefaultsStorageService(userDefaults: mockUserDefaults)
        
        // Then - All countries should still be there
        let reloadedCountries = try await newSut.fetchCountries()
        XCTAssertEqual(reloadedCountries.count, 3)
        XCTAssertTrue(reloadedCountries.contains { $0.id == "US" })
        XCTAssertTrue(reloadedCountries.contains { $0.id == "DE" })
        XCTAssertTrue(reloadedCountries.contains { $0.id == "JP" })
    }
}