//
//  MeasureEnergyModel.swift
//  EnergyWatch WatchKit Extension
//
//  Created by arasan01 on 2022/04/05.
//

import SwiftUI
import Combine
import AppLib

@MainActor
final class MeasureEnergyModel: ObservableObject {
    private let appliances: API.Appliances = API.Appliances()
    
    var timer: Timer?
    var refresh: PassthroughSubject<Void, Never> = .init()
    var timeInterval: TimeInterval = 0
    
    @Published var measureEnergy: String = "-"
    @Published var remaining = 30
    @Published var isExecuting = false
    @Published var lastUpdated: Date = .init(timeIntervalSinceReferenceDate: 0)
    @Published var color: Color = .white
    @Published var nextFireDate: Date?
    @Published var animation: Animation?
    
    func gateKeeper(token: String) -> Bool {
        guard !token.isEmpty else { return false }
        guard !isExecuting else { return false }
        if remaining == 0,
           let nextFireDate = nextFireDate,
           nextFireDate > .now
        {
            return false
        }
        return true
    }
    
    func callMeasure(_ token: String, isValid: Bool) async -> Bool {
        guard isValid else { return false }
        guard gateKeeper(token: token) else { return false }
        timer?.invalidate()
        animation = .none
        isExecuting = true
        defer { isExecuting = false }
        
        do {
            Session.shared.setAuthorization(token: token)
            let (data, limit) = try await Session.shared.send(appliances)
            guard
                let measuredStructure = data?
                    .first?
                    .smartMeter
                    .echonetliteProperties
                    .first(
                        where: { $0.epcIdentifier == .measuredInstantaneous})
            else { return false }
            dump(limit)
            dump(data!)
            measureEnergy = String(Int(measuredStructure.val))
            remaining = limit.remaining
            color = self.lastUpdated == measuredStructure.updatedAt
            ? .white
            : .green
            self.lastUpdated = measuredStructure.updatedAt
            
            let now = Date.now
            if limit.remaining == 0 {
                nextFireDate = limit.reset.advanced(by: 1.0)
            } else {
                nextFireDate = now.advanced(by: 11)
            }
            
            timeInterval = nextFireDate!.timeIntervalSince(now)
            timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: false, block: { [weak self] timer in
                self?.refresh.send()
            })
            animation = .linear(duration: timeInterval)
            
            return true
        } catch {
            return false
        }
    }
}
