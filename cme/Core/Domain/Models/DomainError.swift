import Foundation

enum DomainError: LocalizedError {
    case maxCountriesReached(limit: Int)
    case duplicateCountry(name: String)
    case networkError(NetworkError)
    case storageError(Error)
    case locationDenied
    case locationUnavailable
    case invalidData
    case countryNotFound
    
    var errorDescription: String? {
        switch self {
        case .maxCountriesReached(let limit):
            return "You can only add up to \(limit) countries to your list"
        case .duplicateCountry(let name):
            return "\(name) is already in your list"
        case .networkError(let error):
            return error.localizedDescription
        case .storageError:
            return "Failed to save data"
        case .locationDenied:
            return "Location access is required to detect your country"
        case .locationUnavailable:
            return "Unable to determine your location"
        case .invalidData:
            return "Invalid data received"
        case .countryNotFound:
            return "Country not found"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .maxCountriesReached:
            return "Remove a country from your list to add a new one"
        case .duplicateCountry:
            return "This country is already in your favorites"
        case .networkError:
            return "Please check your internet connection and try again"
        case .locationDenied:
            return "Enable location services in Settings to use this feature"
        default:
            return nil
        }
    }
}