//
//  File.swift
//
//
//  Created by 新山響生 on 2022/04/03.
//

import XCTest
@testable import AppLib

final class RequestTests: XCTestCase {
    func testRequest() async throws {
        let request = API.Appliances()
        Session.shared.setMode(.default)
        Session.shared.setAuthorization(token: "Token")
        let (data, limit) =  try await Session.shared.send(request)
        dump(limit)
        dump(data)
    }

    func testMock() async throws {
        let request = API.Appliances()
        let (data, limit) =  try await Session.shared.send(request)
        dump(limit)
        dump(data)
    }
}
