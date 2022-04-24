//
//  SettingView.swift
//  EnergyWatch WatchKit Extension
//
//  Created by arasan01 on 2022/04/06.
//

import SwiftUI
import AppLib

struct SettingView: View {
    @EnvironmentObject var tokenObject: TokenObject
    
    var body: some View {
        VStack(spacing: 20) {
            SecureField(text: $tokenObject.token) {
                Text("Setup Token")
            }
            .disableAutocorrection(true)
            .onSubmit {
                Task {
                    tokenObject.updateToken(tokenObject.token)
                    if !tokenObject.token.isEmpty {
                        do {
                            let _ = try await Session.shared.send(API.Appliances())
                            tokenObject.updateValidate(true)
                        } catch {
                            tokenObject.updateValidate(false)
                        }
                    } else {
                        tokenObject.updateValidate(false)
                    }
                }
            }
            if tokenObject.validate {
                Text("Token Valid")
            } else {
                Text("Token Invalid")
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
