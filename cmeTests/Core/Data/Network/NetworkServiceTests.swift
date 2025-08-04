import XCTest
@testable import cme

final class NetworkServiceTests: XCTestCase {
    var sut: TestableNetworkService!
    var configuration: APIConfiguration!
    var session: URLSession!
    
    override func setUp() async throws {
        try await super.setUp()
        
        configuration = APIConfiguration(
            baseURL: "https://api.test.com",
            timeout: 30
        )
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: sessionConfig)
        
        sut = TestableNetworkService(configuration: configuration, session: session)
        MockURLProtocol.reset()
    }
    
    override func tearDown() async throws {
        sut = nil
        configuration = nil
        session = nil
        MockURLProtocol.reset()
        try await super.tearDown()
    }
    
    func testFetchSuccess() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        let testData = TestModel(id: 1, name: "Test")
        let jsonData = try JSONEncoder().encode(testData)
        
        MockURLProtocol.mockResponse(for: expectedURL, data: jsonData, statusCode: 200)
        
        // When
        let result: TestModel = try await sut.fetch(endpoint)
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "Test")
    }
    
    func testFetchInvalidURL() async throws {
        // Given
        let invalidEndpoint = "\n\t\r"
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(invalidEndpoint)
            XCTFail("Should throw invalidURL error")
        } catch let error as NetworkError {
            if case .invalidURL = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchDecodingFailed() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        let invalidJSON = "invalid json".data(using: .utf8)!
        
        MockURLProtocol.mockResponse(for: expectedURL, data: invalidJSON, statusCode: 200)
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw decodingFailed error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchClientError() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(for: expectedURL, data: nil, statusCode: 404)
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw serverError")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchServerError() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(for: expectedURL, data: nil, statusCode: 500)
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw serverError")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchTimeout() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(
            for: expectedURL,
            data: nil,
            statusCode: 200,
            error: URLError(.timedOut)
        )
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw timeout error")
        } catch let error as NetworkError {
            if case .timeout = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchNoInternet() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(
            for: expectedURL,
            data: nil,
            statusCode: 200,
            error: URLError(.notConnectedToInternet)
        )
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw noInternet error")
        } catch let error as NetworkError {
            if case .noInternet = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchNetworkConnectionLost() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(
            for: expectedURL,
            data: nil,
            statusCode: 200,
            error: URLError(.networkConnectionLost)
        )
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw noInternet error")
        } catch let error as NetworkError {
            if case .noInternet = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchUnknownError() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        let unknownError = URLError(.unknown)
        
        MockURLProtocol.mockResponse(
            for: expectedURL,
            data: nil,
            statusCode: 200,
            error: unknownError
        )
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw unknown error")
        } catch let error as NetworkError {
            if case .unknown(let underlyingError) = error {
                XCTAssertTrue(underlyingError is URLError)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testFetchInvalidStatusCode() async throws {
        // Given
        let endpoint = "/test"
        let expectedURL = "\(configuration.baseURL)\(endpoint)"
        
        MockURLProtocol.mockResponse(for: expectedURL, data: nil, statusCode: 301)
        
        // When & Then
        do {
            let _: TestModel = try await sut.fetch(endpoint)
            XCTFail("Should throw invalidResponse error")
        } catch let error as NetworkError {
            if case .invalidResponse = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
}

// MARK: - Test Model

private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}