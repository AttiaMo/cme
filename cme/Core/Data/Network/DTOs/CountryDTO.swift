import Foundation

struct CountryDTO: Codable {
    let name: String?
    let capital: String?
    let currencies: [CurrencyDTO]?
    let alpha2Code: String?
    let flags: FlagsDTO?
}

struct FlagsDTO: Codable {
    let svg: String?
    let png: String?
}

extension CountryDTO {
    func toDomainModel() -> Country? {
        guard let name = name, let alpha2Code = alpha2Code else { return nil }
        
        let currencies = self.currencies?.compactMap { $0.toDomainModel() } ?? []
        let flagURL = flags?.png.flatMap { URL(string: $0) }
        
        return Country(
            id: alpha2Code,
            name: name,
            capital: capital,
            currencies: currencies,
            flagPNGUrl: flagURL
        )
    }
}