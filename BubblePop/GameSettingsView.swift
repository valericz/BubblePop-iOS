//
//  GameSettingsView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 2/4/2025.
//

import SwiftUI

struct SliderTickMarksView: View {
    let numberOfTicks: Int
    let width: CGFloat
    let height: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let sliderWidth = geometry.size.width
                let paddingCorrection: CGFloat = 14
                let effectiveWidth = sliderWidth - paddingCorrection * 2
                let step = effectiveWidth / CGFloat(max(numberOfTicks - 1, 1))
                
                ForEach(0..<numberOfTicks, id: \.self) { index in
                    Rectangle()
                        .frame(width: 1, height: height)
                        .foregroundColor(.gray.opacity(0.6))
                        .position(x: CGFloat(index) * step + paddingCorrection, y: height / 2)
                }
            }
            .frame(width: width, height: height)
        }
    }
}


struct GameSettingsView: View {
    @ObservedObject var highScoreViewModel = HighScoreViewModel()
    @State var countDownInput : String = ""
    @State private var countdownValue: Double = 0
    @State private var numberOfBubbles: Double = 0
    var body: some View {
        VStack {
            Label("Setting", systemImage: "")
                .foregroundStyle(.purple)
                .font(.title)
            Spacer()
            Text("Game Time")
            ZStack(alignment: .topLeading) {
                Slider(value: $countdownValue, in: 0...60, step: 1)
                    .frame(width: 300)
                    .padding(.top, 8)
                
                SliderTickMarksView(numberOfTicks: 4, width: 300)
                    .offset(y: -4)
            }
            Text("\(Int(countdownValue))")
            Text("Max Number of Bubbles")
            
            ZStack(alignment: .topLeading) {
                Slider(value: $numberOfBubbles, in: 0...15, step: 1)
                    .frame(width: 300)
                    .padding(.top, 8)
                
                SliderTickMarksView(numberOfTicks: 4, width: 300)
                    .offset(y: -4)
                
            }
            
            Text("\(Int(numberOfBubbles))")
                .padding()
            Spacer()
            NavigationLink(
                destination: GameView(playerName: "Airvendor", gameTime: Int(countdownValue), maxBubbles: Int(numberOfBubbles))
            ) {
                Text("Start Game")
            }
            
            
            
        }
    }
}
#Preview {
    GameSettingsView()
}

