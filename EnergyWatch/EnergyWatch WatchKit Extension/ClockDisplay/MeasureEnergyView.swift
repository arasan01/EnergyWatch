//
//  ContentView.swift
//  EnergyWatch WatchKit Extension
//
//  Created by arasan01 on 2022/04/03.
//

import SwiftUI


struct MeasureEnergyView: View {
    @StateObject var model: MeasureEnergyModel = MeasureEnergyModel()
    @EnvironmentObject var tokenObject: TokenObject
    @State var isAnimated: Bool = true
    
    var body: some View {
        Circle()
            .offset(x: -3, y: 0)
            .trim(from: 0, to: isAnimated ? 1.0 : 0)
            .stroke(lineWidth: 3)
            .rotationEffect(.degrees(-90))
            .foregroundColor(model.color)
            .overlay {
                VStack(alignment: .center, spacing: -5) {
                    Text("現在")
                        .font(.caption)
                    Text(model.measureEnergy)
                        .font(.system(size: 52))
                    Text("Watt")
                        .font(.footnote)
                }
            }
            .onReceive(model.refresh) { _ in
                Task {
                    if await model.callMeasure(tokenObject.token, isValid: tokenObject.validate) {
                        isAnimated = false
                        withAnimation(model.animation) {
                            isAnimated = true
                        }
                    }
                }
            }
            .onAppear {
                model.refresh.send()
            }
            .onDisappear {
                model.timer?.invalidate()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let devices = [
        "Apple Watch Series 6 - 40mm",
        "Apple Watch Series 6 - 44mm",
        "Apple Watch Series 7 - 41mm",
        "Apple Watch Series 7 - 45mm",
    ]
    static var previews: some View {
        ForEach(devices, id: \.self) { device in
            MeasureEnergyView()
                .previewDevice(.init(rawValue: device))
                .previewDisplayName(device)
        }
    }
}
