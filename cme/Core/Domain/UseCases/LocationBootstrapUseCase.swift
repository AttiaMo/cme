import Foundation

actor LocationBootstrapUseCase {
    private let locationService: LocationServiceProtocol
    private let repository: CountryRepositoryProtocol
    private let defaultCountryCode: String
    
    init(
        locationService: LocationServiceProtocol,
        repository: CountryRepositoryProtocol,
        defaultCountryCode: String = AppConstants.defaultCountryCode
    ) {
        self.locationService = locationService
        self.repository = repository
        self.defaultCountryCode = defaultCountryCode
    }
    
    func bootstrap() async throws -> Country? {
        do {
            let countryCode = try await locationService.getCurrentCountryCode()
            return try await findCountryByCode(countryCode)
        } catch {
            // Always fall back to default country for any error
            // This includes permission denied, network errors, etc.
            return try await findCountryByCode(defaultCountryCode)
        }
    }
    
    private func findCountryByCode(_ code: String) async throws -> Country? {
        return try await repository.fetchCountryByCode(code)
    }
}
