import Foundation

enum AppConstants {
    // Search Configuration
    static let minSearchLength = 2
    static let searchDebounceTime: UInt64 = 500_000_000 // 500ms in nanoseconds
    
    // Country Limits
    static let maxCountriesLimit = 5
    
    // Default Values
    static let defaultCountryCode = "DE"
    
    // Network Configuration
    static let networkTimeout: TimeInterval = 30
    static let apiBaseURL = "https://restcountries.com/v2"
    
    // API Fields
    static let apiFields = "name,capital,currencies,alpha2Code,flags"
}