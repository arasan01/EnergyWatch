//
//  EnergyWatchApp.swift
//  EnergyWatch WatchKit Extension
//
//  Created by arasan01 on 2022/04/03.
//

import SwiftUI
import AppLib

final class TokenObject: ObservableObject {
    static let tokenKey = "token"
    static let tokenValidateKey = "tokenValidate"
    
    @Published var token: String
    @Published var validate: Bool
    
    func updateToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: Self.tokenKey)
        Session.shared.setAuthorization(token: token)
        self.token = token
    }
    
    func updateValidate(_ validate: Bool) {
        UserDefaults.standard.set(validate, forKey: Self.tokenValidateKey)
        self.validate = validate
    }
    
    init() {
        self.token = UserDefaults.standard.string(forKey: Self.tokenKey) ?? ""
        self.validate = UserDefaults.standard.bool(forKey: Self.tokenValidateKey)
    }
}


@main
struct EnergyWatchApp: App {
 
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                TabLevelView()
                    .environmentObject(TokenObject())
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

struct TabLevelView: View {
    @EnvironmentObject var tokenObject: TokenObject
    
    var body: some View {
        TabView {
            MeasureEnergyView()
            SettingView()
        }
        .tabViewStyle(.page)
        .onAppear {
            Session.shared.setMode(.default)
        }
    }
}
