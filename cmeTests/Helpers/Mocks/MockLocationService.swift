import Foundation
@testable import cme

class MockLocationService: LocationServiceProtocol {
    var mockCountryCode: String?
    var shouldThrowError = false
    var errorToThrow: Error = DomainError.locationDenied
    var getCurrentCountryCodeCallCount = 0
    
    func getCurrentCountryCode() async throws -> String {
        getCurrentCountryCodeCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        if let code = mockCountryCode {
            return code
        }
        throw DomainError.locationUnavailable
    }
}