import XCTest
@testable import cme

final class cmeTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testCountryEquality() {
        let country1 = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: URL(string: "https://flagcdn.com/w320/us.png")
        )
        
        let country2 = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flagPNGUrl: URL(string: "https://flagcdn.com/w320/us.png")
        )
        
        XCTAssertEqual(country1, country2)
    }
    
    func testCurrencyEquality() {
        let currency1 = Currency(code: "USD", name: "US Dollar", symbol: "$")
        let currency2 = Currency(code: "USD", name: "US Dollar", symbol: "$")
        
        XCTAssertEqual(currency1, currency2)
    }
    
    func testCountryDisplayCapital() {
        let countryWithCapital = Country(
            id: "US",
            name: "United States",
            capital: "Washington D.C.",
            currencies: [],
            flagPNGUrl: nil
        )
        
        let countryWithoutCapital = Country(
            id: "AQ",
            name: "Antarctica",
            capital: nil,
            currencies: [],
            flagPNGUrl: nil
        )
        
        XCTAssertEqual(countryWithCapital.displayCapital, "Washington D.C.")
        XCTAssertEqual(countryWithoutCapital.displayCapital, "No capital")
    }
    
    // MARK: - Domain Error Tests
    
    func testDomainErrorDescriptions() {
        let maxCountriesError = DomainError.maxCountriesReached(limit: 5)
        XCTAssertEqual(maxCountriesError.errorDescription, "You can only add up to 5 countries to your list")
        
        let duplicateError = DomainError.duplicateCountry(name: "Germany")
        XCTAssertEqual(duplicateError.errorDescription, "Germany is already in your list")
        
        let locationDeniedError = DomainError.locationDenied
        XCTAssertEqual(locationDeniedError.errorDescription, "Location access is required to detect your country")
    }
    
    // MARK: - String Extension Tests
    
    func testStringURLEncoding() {
        let normalString = "United States"
        XCTAssertEqual(normalString.urlEncoded, "United%20States")
        
        let specialCharacters = "São Tomé & Príncipe"
        XCTAssertNotNil(specialCharacters.urlEncoded)
    }
}
