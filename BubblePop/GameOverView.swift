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
    @StateObject private var highScoreViewModel = HighScoreViewModel()
    @State private var showScoreboard = false
    @Environment(\.dismiss) private var dismiss
    @State private var returnToMainMenu = false
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Image(systemName: "trophy.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)
            
            Text("You scored \(score) points, \(playerName)!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            
            // Check if this is a new high score
            if let topScore = highScoreViewModel.scores.first?.score, score > topScore {
                Text("🎉 NEW HIGH SCORE! 🎉")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.bottom)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    // Post notification to return to main menu
                    NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Again")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 150)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    showScoreboard = true
                }) {
                    HStack {
                        Image(systemName: "list.number")
                        Text("View Scoreboard")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 180)
                    .background(Color.purple)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.2)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            // Save the score when the view appears
            highScoreViewModel.saveScore(name: playerName, score: score)
        }
        .fullScreenCover(isPresented: $showScoreboard) {
            HighScoreView()
        }
    }
}

#Preview {
    GameOverView(playerName: "AirVendor", score: 123)
}
