//
//  AnalyticsAppApp.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import SwiftUI

@main
struct AnalyticsAppApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
//    init() {
//        Analytics.configure()
//    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
