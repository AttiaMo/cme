import Foundation

struct Currency: Equatable, Hashable, Sendable {
    let code: String
    let name: String
    let symbol: String?
}