import Foundation
import Observation

@MainActor
@Observable
final class CountryListViewModel {
    let repository: CountryRepositoryProtocol
    private let locationBootstrap: LocationBootstrapUseCase
    
    var countries: [Country] = []
    var isLoading = false
    var error: DomainError?
    var showError = false
    
    init(repository: CountryRepositoryProtocol, locationBootstrap: LocationBootstrapUseCase) {
        self.repository = repository
        self.locationBootstrap = locationBootstrap
    }
    
    func onAppear() async {
        await loadCountries()
    }
    
    func loadCountries() async {
        isLoading = true
        error = nil
        showError = false
        
        do {
            countries = try await repository.getSavedCountries()
            
            // Bootstrap with location if no countries saved
            if countries.isEmpty {
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
            await loadCountries()
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
            await loadCountries()
        } catch let domainError as DomainError {
            self.error = domainError
            self.showError = true
        } catch {
            self.error = .invalidData
            self.showError = true
        }
    }
}