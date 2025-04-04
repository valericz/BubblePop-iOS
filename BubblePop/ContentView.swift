//
//  ContentView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 1/4/2025.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: GameSettingsView()) {
                Text("New Game")
            }

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello, world!")
        }
        .padding()
    }
}

