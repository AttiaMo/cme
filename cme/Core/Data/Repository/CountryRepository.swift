import Foundation

actor CountryRepository: CountryRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    private let maxCountries = AppConstants.maxCountriesLimit
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
    }
    
    func fetchAllCountries() async throws -> [Country] {
        do {
            let dtos: [CountryDTO] = try await networkService.fetch("/all?fields=\(AppConstants.apiFields)")
            return dtos.compactMap { $0.toDomainModel() }
        } catch let error as NetworkError {
            throw DomainError.networkError(error)
        } catch {
            throw DomainError.networkError(.unknown(error))
        }
    }
    
    func fetchCountryByCode(_ code: String) async throws -> Country? {
        do {
            let dto: CountryDTO = try await networkService.fetch("/alpha/\(code)")
            return dto.toDomainModel()
        } catch let error as NetworkError {
            if case .serverError(404) = error {
                return nil
            }
            throw DomainError.networkError(error)
        } catch {
            // Preserve original error context for debugging
            print("[CountryRepository] Unexpected error fetching country \(code): \(error)")
            throw DomainError.networkError(.unknown(error))
        }
    }
    
    func searchCountries(query: String) async throws -> [Country] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }
        
        guard let encodedQuery = trimmedQuery.urlEncoded else {
            throw DomainError.invalidData
        }
        
        do {
            let endpoint = "/name/\(encodedQuery)?fields=\(AppConstants.apiFields)"
            let dtos: [CountryDTO] = try await networkService.fetch(endpoint)
            return dtos.compactMap { $0.toDomainModel() }
        } catch let error as NetworkError {
            if case .serverError(404) = error {
                return []
            }
            throw DomainError.networkError(error)
        } catch {
            throw DomainError.networkError(.unknown(error))
        }
    }
    
    func getSavedCountries() async throws -> [Country] {
        do {
            return try await storageService.fetchCountries()
        } catch {
            throw DomainError.storageError(error)
        }
    }
    
    func addCountry(_ country: Country) async throws {
        do {
            let savedCountries = try await storageService.fetchCountries()
            
            // Check max limit
            guard savedCountries.count < maxCountries else {
                throw DomainError.maxCountriesReached(limit: maxCountries)
            }
            
            // Check for duplicates
            guard !savedCountries.contains(where: { $0.id == country.id }) else {
                throw DomainError.duplicateCountry(name: country.name)
            }
            
            try await storageService.save(country)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.storageError(error)
        }
    }
    
    func removeCountry(_ country: Country) async throws {
        do {
            try await storageService.remove(country)
        } catch {
            throw DomainError.storageError(error)
        }
    }
}