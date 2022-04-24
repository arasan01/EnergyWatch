import Foundation

let appliancesDecoder: JSONDecoder = {
    var decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

public typealias AppliancesType = [Appliance]

public struct Appliance: Decodable {
    public let smartMeter: SmartMeter
}

public struct SmartMeter: Decodable {
    public let echonetliteProperties: [MeterProperty]
}

public struct MeterProperty: Decodable {
    enum JSONKeys: String, CodingKey {
        case name, epc, val, updatedAt
    }
    
    public enum EPCIdentifier: Int {
        case coefficient = 211
        case cumulativeElectricEnergyEffectiveDigits = 215
        case normalDirectionCumulativeElectricEnergy = 224
        case cumulativeElectricEnergyUnit = 225
        case reverseDirectionCumulativeElectricEnergy = 227
        case measuredInstantaneous = 231
    }
    
    public let name: String
    public let epcIdentifier: EPCIdentifier
    public let val: Float
    public let updatedAt: Date // ISO8601,UTC "2022-04-03T10:48:16Z"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.epcIdentifier = try EPCIdentifier(
            rawValue: container.decode(Int.self, forKey: .epc))!
        self.val = try Float(container.decode(String.self, forKey: .val))!
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
