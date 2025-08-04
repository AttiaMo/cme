import Foundation
@testable import cme

class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: Error?
    var fetchCallCount = 0
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        fetchCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        if let response = mockResponse as? T {
            return response
        }
        
        throw NetworkError.invalidResponse
    }
}