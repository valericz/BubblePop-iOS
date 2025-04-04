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
    var body: some View {
        VStack{
            Text("Game Over")
                .font(.largeTitle)
                .padding()
            
            Text("Time's up")
            Text("Your final score is:\(score)")
        }
    }
}

#Preview {
    GameOverView(playerName: "AirVendor", score: 123)
}
