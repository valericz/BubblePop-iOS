//
//  BubblePopApp.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 1/4/2025.
//

import SwiftUI

@main
struct BubblePopApp: App {
    @StateObject private var navigationState = NavigationState()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView(gameTime: 60)
                .environmentObject(navigationState)
        }
    }
}
