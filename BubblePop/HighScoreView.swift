//
//  HighScoreView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 2/4/2025.
//

import SwiftUI

struct HighScoreView: View {
    @StateObject private var viewModel = HighScoreViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var returnToMainMenu = false
    
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .padding()
            
            if viewModel.scores.isEmpty {
                Text("No scores yet! Play a game to set a high score.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.scores) { score in
                        HStack {
                            Text(score.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(score.score)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Button("Return to Main Menu") {
                // This will close all modal presentations and return to the main menu
                returnToMainMenu = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.loadScores()
        }
        .fullScreenCover(isPresented: $returnToMainMenu) {
            // This is a trick to return to the main view - we present a full screen cover
            // that immediately dismisses itself and everything else
            ZStack {
                Color.clear
                    .onAppear {
                        // Dismiss everything and return to main menu
                        // We need to wait a tiny bit for the view to appear first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
                            dismiss()
                        }
                    }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HighScoreView()
}
