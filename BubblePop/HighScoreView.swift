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
                // Post notification first
                NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
                
                // Then dismiss both this view and the GameOverView
                dismiss()
                
                // Post the notification again with a slight delay to ensure it's received
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
                }
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
    }
}

#Preview {
    HighScoreView()
}
