//
//  WelcomeView.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 1/4/2025.
//

import SwiftUI

struct WelcomeView: View {
    @State private var playerName: String = ""
    @State private var showGameView = false
    var gameTime: Int = 60
    var maxBubbles: Int = 15
    var body: some View {
        NavigationStack{
            VStack(spacing:20){
                Text("Welcode to BubblePop🫧")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .bold()
                
                }
                
                TextField("Please enter your name:",text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal,40)
          
                
                Button(action:{
                    if !playerName.isEmpty {
                        showGameView = true
                    }
                }) {
                    Text("Start Game🚀")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width:200, height:50)
                        .background(playerName.isEmpty ? Color.gray:Color.blue)
                        .cornerRadius(10)
                }
                .disabled(playerName.isEmpty)
            NavigationLink(destination: GameSettingsView()){
                Text("Settings")
                    .font(.title2)
                    .padding()
                    .background(playerName.isEmpty ? Color.gray:Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(playerName.isEmpty)
            }
            .fullScreenCover(isPresented:$showGameView){
                GameView(playerName:playerName, gameTime:gameTime ,maxBubbles: maxBubbles)
            }
            
            
        }
    }

#Preview {
    WelcomeView()
}
