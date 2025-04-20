//
//  GameOverView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 2/4/2025.
//

import SwiftUI

struct GameOverView: View {
    var playerName: String
    var score: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showScoreboard = false
    @EnvironmentObject private var navigationState: NavigationState
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Time's up")
                .font(.title2)
            
            Text("You scored \(score) points, \(playerName)!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            // Play Again button
            Button(action: {
                // Dismiss this view to return to the game
                dismiss()
            }) {
                Text("Play Again")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            // View Scoreboard button
            Button(action: {
                // Show the scoreboard
                showScoreboard = true
            }) {
                Text("View Scoreboard")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            
            // Return to Main Menu button
            Button(action: {
                // Signal to return to root view
                navigationState.returnToRoot = true
                dismiss()
            }) {
                Text("Return to Main Menu")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $showScoreboard) {
            ScoreBoardView()
                .environmentObject(navigationState)
        }
        .onAppear {
            // Save the score when the view appears
            let highScoreVM = HighScoreViewModel()
            highScoreVM.saveScore(name: playerName, score: score)
        }
    }
}

#Preview {
    GameOverView(playerName: "Player", score: 123)
        .environmentObject(NavigationState())
}
