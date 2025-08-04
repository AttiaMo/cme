import Foundation

struct Country: Identifiable, Equatable, Hashable, Sendable, Codable {
    let id: String
    let name: String
    let capital: String?
    let currencies: [Currency]
    let flagPNGUrl: URL?
    
    var displayCapital: String {
        capital ?? "No capital"
    }
}