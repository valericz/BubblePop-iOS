//
//  ScoreBoardView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 2/4/2025.
//

import SwiftUI

struct ScoreBoardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HighScoreViewModel()
    
    var body: some View {
        VStack {
            Text("High Scores 🏆")
                .font(.custom("HelveticaNeue-Bold", size: 28))
                .padding(.top, 20)
            
            if viewModel.scores.isEmpty {
                Spacer()
                Text("No scores yet! Be the first to play!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(0..<viewModel.scores.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            
                            Text(viewModel.scores[index].name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(viewModel.scores[index].score)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Back to Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.loadScores()
        }
    }
}

#Preview {
    ScoreBoardView()
}
