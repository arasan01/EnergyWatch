//
//  ContentView.swift
//  EnergyWatch WatchKit Extension
//
//  Created by 新山響生 on 2022/04/03.
//

import SwiftUI


struct MeasureEnergyView: View {
    @State var count: CGFloat = 0.7
    
    var body: some View {
        Circle()
            .trim(from: 0, to: count)
            .stroke(lineWidth: 3)
            .rotationEffect(.degrees(-90))
            .overlay {
                VStack(alignment: .center, spacing: -5) {
                    Text("現在")
                        .font(.footnote)
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("0")
                            .font(.system(size: 53))
                        Text("W")
                            .font(.caption)
                    }
                }
            }
            .onTapGesture {
                <#code#>
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
