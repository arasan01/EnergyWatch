import XCTest
@testable import AppLib

final class ObjectTests: XCTestCase {
    func testDecode() throws {
        let json = API.Appliances().mockData
        let decoded = try appliancesDecoder.decode(AppliancesType.self, from: json)
        dump(decoded)
    }
}
