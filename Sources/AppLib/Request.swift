import Foundation

public enum HTTPMethod: String { case get }

public protocol Request {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headerFields: [String: String] { get }
    var mockData: Data { get }
    associatedtype Response: Decodable
}

public extension Request {
    var baseURL: URL { URL(string: "https://api.nature.global")! }
    var headerFields: [String : String] { [:] }
}

extension Request {
    func makeURLRequest(authorizationToken: String? = nil) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        var headerFields = self.headerFields
        if let token = authorizationToken {
            headerFields["Authorization"] = "Bearer \(token)"
        }
        request.allHTTPHeaderFields = headerFields
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
