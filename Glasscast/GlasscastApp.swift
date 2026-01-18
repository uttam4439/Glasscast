//
//  GlasscastApp.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI

@main
struct GlasscastApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

