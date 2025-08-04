import Foundation

struct Currency: Equatable, Hashable, Sendable, Codable {
    let code: String
    let name: String
    let symbol: String?
}