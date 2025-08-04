import Foundation

@MainActor
final class AppConfiguration {
    let networkService: NetworkServiceProtocol
    let storageService: StorageServiceProtocol
    let locationService: LocationServiceProtocol
    let countryRepository: CountryRepositoryProtocol
    let locationBootstrapUseCase: LocationBootstrapUseCase
    
    init() {
        let apiConfig = APIConfiguration(
            baseURL: AppConstants.apiBaseURL,
            timeout: AppConstants.networkTimeout
        )
        
        self.networkService = NetworkService(configuration: apiConfig)
        
        // Use UserDefaults for persistent storage
        // This can easily be replaced with any other storage implementation
        // that conforms to StorageServiceProtocol (e.g., CoreData, SwiftData, SQLite)
        self.storageService = UserDefaultsStorageService()
        
        self.locationService = LocationService()
        self.countryRepository = CountryRepository(
            networkService: networkService,
            storageService: storageService
        )
        self.locationBootstrapUseCase = LocationBootstrapUseCase(
            locationService: locationService,
            repository: countryRepository
        )
    }
}