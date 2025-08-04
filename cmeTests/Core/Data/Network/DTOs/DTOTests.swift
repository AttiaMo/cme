import XCTest
@testable import cme

final class DTOTests: XCTestCase {
    
    // MARK: - CountryDTO Tests
    
    func testCountryDTODecodingSuccess() throws {
        // Given
        let jsonData = CountryDTOFixtures.validCountryJSON
        
        // When
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // Then
        XCTAssertEqual(countryDTO.name, "Germany")
        XCTAssertEqual(countryDTO.capital, "Berlin")
        XCTAssertEqual(countryDTO.alpha2Code, "DE")
        XCTAssertEqual(countryDTO.currencies?.count, 1)
        XCTAssertEqual(countryDTO.currencies?.first?.code, "EUR")
        XCTAssertEqual(countryDTO.currencies?.first?.name, "Euro")
        XCTAssertEqual(countryDTO.currencies?.first?.symbol, "€")
        XCTAssertEqual(countryDTO.flags?.png, "https://flagcdn.com/w320/de.png")
        XCTAssertEqual(countryDTO.flags?.svg, "https://flagcdn.com/de.svg")
    }
    
    func testCountryDTOWithMultipleCurrencies() throws {
        // Given
        let jsonData = CountryDTOFixtures.countryWithMultipleCurrenciesJSON
        
        // When
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // Then
        XCTAssertEqual(countryDTO.name, "Switzerland")
        XCTAssertEqual(countryDTO.capital, "Bern")
        XCTAssertEqual(countryDTO.currencies?.count, 2)
        
        let currencyCodes = countryDTO.currencies?.compactMap { $0.code } ?? []
        XCTAssertTrue(currencyCodes.contains("CHF"))
        XCTAssertTrue(currencyCodes.contains("EUR"))
    }
    
    func testCountryDTOWithoutCapital() throws {
        // Given
        let jsonData = CountryDTOFixtures.countryWithoutCapitalJSON
        
        // When
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // Then
        XCTAssertEqual(countryDTO.name, "Antarctica")
        XCTAssertNil(countryDTO.capital)
        XCTAssertEqual(countryDTO.alpha2Code, "AQ")
        XCTAssertTrue(countryDTO.currencies?.isEmpty ?? true)
    }
    
    func testCountryDTOWithoutCurrencies() throws {
        // Given
        let jsonData = CountryDTOFixtures.countryWithoutCurrenciesJSON
        
        // When
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // Then
        XCTAssertEqual(countryDTO.name, "United States")
        XCTAssertEqual(countryDTO.capital, "Washington, D.C.")
        XCTAssertNil(countryDTO.currencies)
    }
    
    func testCountryDTOArrayDecoding() throws {
        // Given
        let jsonData = CountryDTOFixtures.countryArrayJSON
        
        // When
        let countries = try JSONDecoder().decode([CountryDTO].self, from: jsonData)
        
        // Then
        XCTAssertEqual(countries.count, 2)
        XCTAssertEqual(countries[0].name, "Germany")
        XCTAssertEqual(countries[1].name, "United States")
    }
    
    func testCountryDTOInvalidJSONSucceedsWithOptionals() {
        // Given
        let jsonData = CountryDTOFixtures.invalidJSON
        
        // When
        let countryDTO = try? JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // Then - All fields are optional, so it should decode successfully with nil values
        XCTAssertNotNil(countryDTO)
        XCTAssertNil(countryDTO?.name)
        XCTAssertNil(countryDTO?.capital)
        XCTAssertNil(countryDTO?.alpha2Code)
        XCTAssertNil(countryDTO?.currencies)
        XCTAssertNil(countryDTO?.flags)
    }
    
    func testCountryDTOMalformedJSONThrows() {
        // Given
        let jsonData = CountryDTOFixtures.malformedJSON
        
        // When & Then
        XCTAssertThrowsError(try JSONDecoder().decode(CountryDTO.self, from: jsonData))
    }
    
    // MARK: - Domain Model Conversion Tests
    
    func testCountryDTOToDomainModel() throws {
        // Given
        let jsonData = CountryDTOFixtures.validCountryJSON
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // When
        let country = countryDTO.toDomainModel()
        
        // Then
        XCTAssertNotNil(country)
        XCTAssertEqual(country?.id, "DE")
        XCTAssertEqual(country?.name, "Germany")
        XCTAssertEqual(country?.capital, "Berlin")
        XCTAssertEqual(country?.currencies.count, 1)
        XCTAssertEqual(country?.currencies.first?.code, "EUR")
        XCTAssertNotNil(country?.flagPNGUrl)
        XCTAssertEqual(country?.flagPNGUrl?.absoluteString, "https://flagcdn.com/w320/de.png")
    }
    
    func testCountryDTOWithNilCapitalToDomainModel() throws {
        // Given
        let jsonData = CountryDTOFixtures.countryWithoutCapitalJSON
        let countryDTO = try JSONDecoder().decode(CountryDTO.self, from: jsonData)
        
        // When
        let country = countryDTO.toDomainModel()
        
        // Then
        XCTAssertNotNil(country)
        XCTAssertEqual(country?.id, "AQ")
        XCTAssertEqual(country?.name, "Antarctica")
        XCTAssertNil(country?.capital)
        XCTAssertTrue(country?.currencies.isEmpty ?? true)
        XCTAssertEqual(country?.displayCapital, "No capital")
    }
    
    // MARK: - CurrencyDTO Tests
    
    func testCurrencyDTOEquality() {
        // Given
        let currency1 = CurrencyDTO(code: "USD", name: "US Dollar", symbol: "$")
        let currency2 = CurrencyDTO(code: "USD", name: "US Dollar", symbol: "$")
        let currency3 = CurrencyDTO(code: "EUR", name: "Euro", symbol: "€")
        
        // Then
        // CurrencyDTO doesn't conform to Equatable, so we test properties instead
        XCTAssertEqual(currency1.code, currency2.code)
        XCTAssertEqual(currency1.name, currency2.name)
        XCTAssertEqual(currency1.symbol, currency2.symbol)
        XCTAssertNotEqual(currency1.code, currency3.code)
    }
    
    func testCurrencyDTOToDomainModel() {
        // Given
        let currencyDTO = CurrencyDTO(code: "USD", name: "US Dollar", symbol: "$")
        
        // When
        let currency = currencyDTO.toDomainModel()
        
        // Then
        XCTAssertNotNil(currency)
        XCTAssertEqual(currency?.code, "USD")
        XCTAssertEqual(currency?.name, "US Dollar")
        XCTAssertEqual(currency?.symbol, "$")
    }
    
    // MARK: - FlagsDTO Tests
    
    func testFlagsDTOInitialization() {
        // Given & When
        let flags = FlagsDTO(svg: "https://flagcdn.com/de.svg", png: "https://flagcdn.com/w320/de.png")
        
        // Then
        XCTAssertEqual(flags.svg, "https://flagcdn.com/de.svg")
        XCTAssertEqual(flags.png, "https://flagcdn.com/w320/de.png")
    }
    
    func testFlagsDTOWithNilValues() {
        // Given & When
        let flags = FlagsDTO(svg: nil, png: nil)
        
        // Then
        XCTAssertNil(flags.svg)
        XCTAssertNil(flags.png)
    }
}