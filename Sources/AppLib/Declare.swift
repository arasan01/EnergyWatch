import Foundation

public enum API {
    public struct Appliances: Request {
        public init() {}
        
        public let path: String = "/1/appliances"
        public let method: HTTPMethod = .get
        public typealias Response = AppliancesType
        public var mockData: Data {
            let url = Bundle.module.url(forResource: "appliances", withExtension: "json")!
            return try! Data(contentsOf: url)
        }
    }
}
