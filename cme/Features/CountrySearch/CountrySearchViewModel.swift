import Foundation
import Observation

@MainActor
@Observable
final class CountrySearchViewModel {
    private let repository: CountryRepositoryProtocol
    
    var searchText = ""
    var searchResults: [Country] = []
    var isSearching = false
    var error: DomainError?
    var showError = false
    
    private var searchTask: Task<Void, Never>?
    
    init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    func search() {
        searchTask?.cancel()
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            self.isSearching = true
            self.error = nil
            self.showError = false
            
            // Debounce for 300ms
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
            } catch {
                return // Task was cancelled
            }
            
            do {
                self.searchResults = try await self.repository.searchCountries(query: self.searchText)
                
                // Filter out already saved countries
                let savedCountries = try await self.repository.getSavedCountries()
                let savedIds = Set(savedCountries.map { $0.id })
                self.searchResults = self.searchResults.filter { !savedIds.contains($0.id) }
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