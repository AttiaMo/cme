import Foundation

struct CurrencyDTO: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}

extension CurrencyDTO {
    func toDomainModel() -> Currency? {
        guard let code = code, let name = name else { return nil }
        return Currency(code: code, name: name, symbol: symbol)
    }
}