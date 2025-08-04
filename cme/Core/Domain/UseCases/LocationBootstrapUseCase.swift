import Foundation

actor LocationBootstrapUseCase {
    private let locationService: LocationServiceProtocol
    private let repository: CountryRepositoryProtocol
    private let defaultCountryCode: String
    
    init(
        locationService: LocationServiceProtocol,
        repository: CountryRepositoryProtocol,
        defaultCountryCode: String = "DE"
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
            // Only fall back to default country if it's not a permission issue
            if case DomainError.locationDenied = error {
                // User denied permission, don't try fallback
                return nil
            }
            // For other errors (network, etc.), try fallback
            return try await findCountryByCode(defaultCountryCode)
        }
    }
    
    private func findCountryByCode(_ code: String) async throws -> Country? {
        let countries = try await repository.fetchAllCountries()
        return countries.first { $0.id.caseInsensitiveCompare(code) == .orderedSame }
    }
}