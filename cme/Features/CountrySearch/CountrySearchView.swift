import SwiftUI

struct CountrySearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CountrySearchViewModel
    let onCountrySelected: (Country) -> Void
    
    init(viewModel: CountrySearchViewModel, onCountrySelected: @escaping (Country) -> Void) {
        self._viewModel = State(wrappedValue: viewModel)
        self.onCountrySelected = onCountrySelected
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                    searchPromptView
                } else if viewModel.isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Add Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search countries")
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.search()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.error?.errorDescription ?? "An error occurred")
            }
        }
    }
    
    private var searchPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Search for a country")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Type at least \(AppConstants.minSearchLength) characters to search")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No results found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try searching with a different name")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsList: some View {
        List(viewModel.searchResults) { country in
            SearchResultRow(
                country: country,
                isAlreadySaved: viewModel.savedCountryIds.contains(country.id)
            )
            .onTapGesture {
                if !viewModel.savedCountryIds.contains(country.id) {
                    onCountrySelected(country)
                    dismiss()
                }
                // If already saved, do nothing - the visual indicator shows it's saved
            }
        }
    }
}