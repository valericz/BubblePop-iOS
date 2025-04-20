import SwiftUI

struct SliderTickMarksView: View {
    let numberOfTicks: Int
    let width: CGFloat
    let height: CGFloat = 8
    
    var body: some View {
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

struct GameSettingsView: View {
    @Binding var playerName: String
    @ObservedObject var highScoreViewModel = HighScoreViewModel()
    @State var countDownInput: String = ""
    @State private var countdownValue: Double = 60  // Default to 60 seconds
    @State private var numberOfBubbles: Double = 15  // Default to 15 bubbles
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationState: NavigationState
    @State private var showGameView = false
    
    // Minimum requirements
    private let minTime = 5
    private let minBubbles = 5
    
    // Computed properties for validation
    private var isTimeValid: Bool {
        Int(countdownValue) >= minTime
    }
    
    private var isBubblesValid: Bool {
        Int(numberOfBubbles) >= minBubbles
    }
    
    private var canStartGame: Bool {
        isTimeValid && isBubblesValid
    }
    
    var body: some View {
        VStack {
            // Add a custom back button
            HStack {
                Button(action: {
                    // Go back to the main menu
                    navigationState.returnToRoot = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back to Main Menu")
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
                Spacer()
            }
            
            Label("Settings", systemImage: "gear")
                .foregroundStyle(.purple)
                .font(.title)
                .padding(.bottom)
            
            Spacer()
            
            // Game Time Section
            Text("Game Time")
                .font(.headline)
            
            ZStack(alignment: .topLeading) {
                Slider(value: $countdownValue, in: 0...60, step: 1)
                    .frame(width: 300)
                    .padding(.top, 8)
                    .accentColor(isTimeValid ? .blue : .red)
                
                SliderTickMarksView(numberOfTicks: 4, width: 300)
                    .offset(y: -4)
            }
            
            Text("\(Int(countdownValue)) seconds")
                .foregroundColor(isTimeValid ? .primary : .red)
            
            if !isTimeValid {
                Text("Game time must be at least \(minTime) seconds")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Max Bubbles Section
            Text("Max Number of Bubbles")
                .font(.headline)
                .padding(.top)
            
            ZStack(alignment: .topLeading) {
                Slider(value: $numberOfBubbles, in: 0...15, step: 1)
                    .frame(width: 300)
                    .padding(.top, 8)
                    .accentColor(isBubblesValid ? .blue : .red)
                
                SliderTickMarksView(numberOfTicks: 4, width: 300)
                    .offset(y: -4)
            }
            
            Text("\(Int(numberOfBubbles)) bubbles")
                .foregroundColor(isBubblesValid ? .primary : .red)
            
            if !isBubblesValid {
                Text("Number of bubbles must be at least \(minBubbles)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            // Start Game Button
            Button(action: {
                // Set flag to show game view
                showGameView = true
            }) {
                Text("Start Game")
                    .frame(minWidth: 200)
                    .padding()
                    .background(canStartGame ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!canStartGame)
            
            if !canStartGame {
                Text("Please adjust settings to meet minimum requirements")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 4)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showGameView) {
            GameView(
                playerName: playerName,
                gameTime: max(Int(countdownValue), minTime),
                maxBubbles: max(Int(numberOfBubbles), minBubbles)
            )
            .environmentObject(navigationState)
        }
        .onChange(of: navigationState.returnToRoot) { newValue in
            if newValue {
                // Dismiss this view when return to root is requested
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
