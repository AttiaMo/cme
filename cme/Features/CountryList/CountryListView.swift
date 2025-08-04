import SwiftUI

struct CountryListView: View {
    @State private var viewModel: CountryListViewModel
    @State private var showingSearch = false
    @State private var selectedCountry: Country?
    
    init(viewModel: CountryListViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.countries.isEmpty {
                    ProgressView("Loading countries...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.countries.isEmpty {
                    EmptyStateView(
                        title: "No Countries Added",
                        message: "Add countries to track their capital and currency information",
                        actionTitle: "Add Country",
                        action: { showingSearch = true }
                    )
                } else {
                    countryList
                }
            }
            .navigationTitle("Countries")
            .navigationDestination(item: $selectedCountry) { country in
                CountryDetailView(country: country)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.countries.count < 5 {
                        Button("Add", systemImage: "plus") {
                            showingSearch = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                CountrySearchView(
                    viewModel: viewModel.createSearchViewModel(),
                    onCountrySelected: { country in
                        Task {
                            await viewModel.addCountry(country)
                        }
                    }
                )
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.error?.errorDescription ?? "An error occurred")
            }
            .task {
                await viewModel.onAppear()
            }
        }
    }
    
    private var countryList: some View {
        List {
            ForEach(viewModel.countries) { country in
                CountryRowView(country: country)
                    .onTapGesture {
                        selectedCountry = country
                    }
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        await viewModel.removeCountry(viewModel.countries[index])
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadCountries()
        }
    }
}