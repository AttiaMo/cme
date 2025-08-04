import Foundation

struct APIConfiguration {
    let baseURL: String
    let timeout: TimeInterval
    
    init(baseURL: String = "https://restcountries.com/v2", timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}