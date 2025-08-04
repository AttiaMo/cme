import Foundation

class MockURLProtocol: URLProtocol {
    static var mockResponses: [String: (data: Data?, response: URLResponse?, error: Error?)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url?.absoluteString,
              let mock = MockURLProtocol.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        if let response = mock.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = mock.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let error = mock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
    
    static func mockResponse(for url: String, data: Data? = nil, statusCode: Int = 200, error: Error? = nil) {
        let response = HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        mockResponses[url] = (data, response, error)
    }
    
    static func reset() {
        mockResponses.removeAll()
    }
}