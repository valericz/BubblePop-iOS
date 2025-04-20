import SwiftUI

struct WelcomeView: View {
    @State private var playerName: String = ""
    @State private var showGameView = false
    @State private var showNameTooLongAlert = false // Add this state variable
    @EnvironmentObject private var navigationState: NavigationState
    
    private let maxNameLength = 15
    
    var gameTime: Int = 60
    var maxBubbles: Int = 15
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("BubblePop🫧")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .bold()
                    .padding(.top, 50)
                
                TextField("Please enter your name:", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .onChange(of: playerName) { newValue in
                        // Limit the length by truncating if too long
                        if newValue.count > maxNameLength {
                            playerName = String(newValue.prefix(maxNameLength))
                            showNameTooLongAlert = true
                        }
                    }
                
                // Add character counter below TextField
                Text("\(playerName.count)/\(maxNameLength) characters")
                    .font(.caption)
                    .foregroundColor(playerName.count >= maxNameLength ? .red : .gray)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    if !playerName.isEmpty {
                        showGameView = true
                    }
                }) {
                    Text("Start Game🐙")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 40)
                        .padding()
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(playerName.isEmpty)
                .padding(.top, 20)
                
                NavigationLink(destination: GameSettingsView(playerName: $playerName)
                    .environmentObject(navigationState)) {
                    Text("Settings⚙️")
                        .font(.title2)
                        .frame(width: 200, height: 40)
                        .padding()
                        .background(playerName.isEmpty ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(playerName.isEmpty)
                .padding(.top, 10)
            }
            .padding()
            .fullScreenCover(isPresented: $showGameView) {
                GameView(playerName: playerName, gameTime: gameTime, maxBubbles: maxBubbles)
                    .environmentObject(navigationState)
            }
            .onChange(of: navigationState.returnToRoot) { newValue in
                if newValue {
                    // Reset the navigation state
                    navigationState.returnToRoot = false
                    // Make sure game view is dismissed if it's showing
                    showGameView = false
                }
            }
            .alert("Name Too Long", isPresented: $showNameTooLongAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Player names are limited to \(maxNameLength) characters.")
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(NavigationState())
}
