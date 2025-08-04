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
            baseURL: "https://restcountries.com/v2",
            timeout: 30
        )
        
        self.networkService = NetworkService(configuration: apiConfig)
        self.storageService = InMemoryStorageService()
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