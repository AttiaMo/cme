import Foundation
import Observation

@MainActor
@Observable
final class CountrySearchViewModel {
    private let repository: CountryRepositoryProtocol
    
    var searchText = ""
    private(set) var searchResults: [Country] = []
    private(set) var isSearching = false
    private(set) var error: DomainError?
    var showError = false
    private(set) var savedCountryIds = Set<String>()
    
    private var searchTask: Task<Void, Never>?
    
    init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    func search() {
        searchTask?.cancel()
        
        // Clear any existing errors immediately
        self.error = nil
        self.showError = false
        
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Require minimum characters to search
        guard trimmedText.count >= AppConstants.minSearchLength else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            self.isSearching = true
            
            // Debounce to better handle rapid typing
            do {
                try await Task.sleep(nanoseconds: AppConstants.searchDebounceTime)
            } catch {
                return // Task was cancelled
            }
            
            do {
                self.searchResults = try await self.repository.searchCountries(query: self.searchText)
                
                // Get saved countries to mark them in the UI
                let savedCountries = try await self.repository.getSavedCountries()
                self.savedCountryIds = Set(savedCountries.map { $0.id })
            } catch let domainError as DomainError {
                self.error = domainError
                self.showError = true
                self.searchResults = []
            } catch {
                self.error = .invalidData
                self.showError = true
                self.searchResults = []
            }
            
            self.isSearching = false
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        searchTask?.cancel()
    }
}