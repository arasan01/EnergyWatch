import Foundation

public enum IError: Error { case server(Int), decode, session, callRestricted(RequestLimit), unknown }
extension IError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .server(let code):
            return "Server failure with \(code)"
        case .decode:
            return "Missed decode process"
        case .session:
            return "Missed session connected"
        case .callRestricted(let limit):
            return "Too many requested, wait next reset time at \(limit.reset)"
        case .unknown:
            return "Maybe failed standing connection, or urlsession internal?"
        }
    }
}

public struct RequestLimit {
    public let limit: Int
    public let remaining: Int
    public let reset: Date
    
    init?(limit: String, remaining: String, reset: String) {
        if let limitC = Int(limit),
           let remainingC = Int(remaining),
           let resetTime = TimeInterval(reset) {
            self.limit = limitC
            self.remaining = remainingC
            self.reset = Date(timeIntervalSince1970: resetTime)
        } else {
            return nil
        }
    }
}

public class Session {
    public enum Mode { case `default`, mock}
    public static let shared: Session = Session(session: .shared)
    
    public init(session: URLSession, mode: Mode = .mock) {
        self.session = session
        self.mode = mode
    }
    
    let session: URLSession
    private var mode: Mode
    private var authorizationToken: String?
}

public extension Session {
    func setAuthorization(token: String) {
        self.authorizationToken = token
    }
    
    func setMode(_ mode: Mode) {
        self.mode = mode
    }
    
    func send<T: Request>(_ api: T) async throws -> (T.Response?, RequestLimit) {
        let request = api.makeURLRequest(authorizationToken: authorizationToken)
        let (data, response): (Data, URLResponse)

        do {
            switch mode {
            case .default:
                (data, response) = try await session.data(for: request)
            case .mock:
                (data, response) = (api.mockData, HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/2.0",
                    headerFields: ["x-rate-limit-limit": "30", "x-rate-limit-remaining": "29", "x-rate-limit-reset": "1264217700"])!
                )
            }
        } catch {
            throw IError.unknown
        }
        
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw IError.session
        }
        
        guard
            let limitStr = httpURLResponse.value(forHTTPHeaderField: "x-rate-limit-limit"),
            let remainingStr = httpURLResponse.value(forHTTPHeaderField: "x-rate-limit-remaining"),
            let resetTimeStr = httpURLResponse.value(forHTTPHeaderField: "x-rate-limit-reset"),
            let limit = RequestLimit(limit: limitStr, remaining: remainingStr, reset: resetTimeStr)
        else {
            throw IError.server(httpURLResponse.statusCode)
        }
        
        guard 429 != httpURLResponse.statusCode else {
            return (nil, limit)
        }
        
        guard 200..<300 ~= httpURLResponse.statusCode else {
            throw IError.server(httpURLResponse.statusCode)
        }
        
        let structure: T.Response
        do {
            structure = try appliancesDecoder.decode(T.Response.self, from: data)
        } catch {
            throw IError.decode
        }
        
        return (structure, limit)
    }
}
