import Foundation
import Observation

@MainActor
@Observable
final class CountryListViewModel {
    private let repository: CountryRepositoryProtocol
    private let locationBootstrap: LocationBootstrapUseCase
    
    private(set) var countries: [Country] = []
    private(set) var isLoading = false
    private(set) var error: DomainError?
    var showError = false
    
    init(repository: CountryRepositoryProtocol, locationBootstrap: LocationBootstrapUseCase) {
        self.repository = repository
        self.locationBootstrap = locationBootstrap
    }
    
    func onAppear() async {
        await loadCountries()
    }
    
    func loadCountries(shouldBootstrap: Bool = true) async {
        isLoading = true
        error = nil
        showError = false
        
        do {
            countries = try await repository.getSavedCountries()
            
            // Bootstrap with location if no countries saved and bootstrap is allowed
            if countries.isEmpty && shouldBootstrap {
                if let bootstrapCountry = try await locationBootstrap.bootstrap() {
                    try await repository.addCountry(bootstrapCountry)
                    countries = [bootstrapCountry]
                }
            }
        } catch let domainError as DomainError {
            self.error = domainError
            self.showError = true
        } catch {
            self.error = .invalidData
            self.showError = true
        }
        
        isLoading = false
    }
    
    func removeCountry(_ country: Country) async {
        do {
            try await repository.removeCountry(country)
            // Don't bootstrap after deletion - user explicitly removed the country
            await loadCountries(shouldBootstrap: false)
        } catch let domainError as DomainError {
            self.error = domainError
            self.showError = true
        } catch {
            self.error = .invalidData
            self.showError = true
        }
    }
    
    func addCountry(_ country: Country) async {
        do {
            try await repository.addCountry(country)
            // Don't bootstrap after adding - user explicitly added a country
            await loadCountries(shouldBootstrap: false)
        } catch let domainError as DomainError {
            self.error = domainError
            self.showError = true
        } catch {
            self.error = .invalidData
            self.showError = true
        }
    }
    
    func createSearchViewModel() -> CountrySearchViewModel {
        CountrySearchViewModel(repository: repository)
    }
}