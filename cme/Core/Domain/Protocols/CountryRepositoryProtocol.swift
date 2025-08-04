import Foundation

protocol CountryRepositoryProtocol: Sendable {
    func fetchAllCountries() async throws -> [Country]
    func fetchCountryByCode(_ code: String) async throws -> Country?
    func searchCountries(query: String) async throws -> [Country]
    func getSavedCountries() async throws -> [Country]
    func addCountry(_ country: Country) async throws
    func removeCountry(_ country: Country) async throws
}