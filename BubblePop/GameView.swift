import SwiftUI

struct GameView: View {
    @State var timer: Timer?
    @State private var bubbles: [Bubble] = []
    @State private var remainingTime: Int
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var lastPoppedColor: BubbleColor?
    @State private var gameAreaSize: CGSize = .zero
    @State private var isViewAppeared = false
    @State private var resetCount = 0 // Add a counter to force resets
    @Environment(\.dismiss) private var dismiss // Use the standard dismiss environment
    
    var playerName: String
    var gameTime: Int
    var maxBubbles: Int
    
    init(playerName: String, gameTime: Int, maxBubbles: Int) {
        self.playerName = playerName
        self.gameTime = max(gameTime, 5) // Ensure minimum values
        self.maxBubbles = max(maxBubbles, 5)
        _remainingTime = State(initialValue: max(gameTime, 5))
        print("📱 GameView init with time: \(gameTime), bubbles: \(maxBubbles)")
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Return to main menu
                    NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
                    dismiss()
                }) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding(.leading)
                
                Spacer()
            }
            
            Text("Hello, \(playerName)!")
                .font(.largeTitle)
                .padding()
            
            Text("Your current score is: \(score)")
                .padding()
            
            Text("Time Left: \(remainingTime) seconds")
                .padding()
            
            // Game area with fixed aspect ratio
            ZStack {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: SizePreferenceKey.self, value: geo.size)
                        }
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { size in
                        print("📏 Game area size changed: \(size)")
                        if size != .zero && (gameAreaSize != size || bubbles.isEmpty) {
                            gameAreaSize = size
                            // Force a reset when size changes
                            DispatchQueue.main.async {
                                resetGame(forceReset: true)
                            }
                        }
                    }
                
                // Draw bubbles only if we have a valid game area
                if gameAreaSize != .zero {
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(bubble.color.color)
                            .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                            .position(bubble.position)
                            .onTapGesture {
                                if isGameOver { return }
                                bubbles.removeAll { $0.id == bubble.id }
                                
                                let gainedScore: Int
                                if let lastColor = lastPoppedColor, lastColor == bubble.color {
                                    gainedScore = Int(ceil(Double(bubble.baseScore) * 1.5))
                                } else {
                                    gainedScore = bubble.baseScore
                                }
                                
                                score += gainedScore
                                lastPoppedColor = bubble.color
                                
                                // Create one more bubble with strict bounds checking
                                let newBubbles = generateNonOverlappingBubbles(count: 1, in: gameAreaSize, existing: bubbles)
                                bubbles += newBubbles
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.1)) // Add background to visualize game area
            .onAppear {
                print("🔄 GameView appeared")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    resetGame(forceReset: true)
                }
            }
            .onDisappear {
                print("⏹️ GameView disappeared")
                stopGame()
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isGameOver) {
            GameOverView(playerName: playerName, score: score)
        }
    }
    
    private func stopGame() {
        print("🛑 Stopping game")
        timer?.invalidate()
        timer = nil
    }
    
    private func resetGame(forceReset: Bool = false) {
        // Only reset if we need to
        let needsReset = forceReset || bubbles.isEmpty || resetCount == 0
        
        if !needsReset {
            print("⏭️ Reset not needed")
            return
        }
        
        print("🔄 Resetting game (count: \(resetCount + 1)), gameAreaSize: \(gameAreaSize)")
        resetCount += 1
        
        // Stop existing timer
        stopGame()
        
        // Reset game state
        score = 0
        remainingTime = gameTime
        isGameOver = false
        lastPoppedColor = nil
        bubbles = []
        
        // Ensure we have a valid game area
        guard gameAreaSize.width > 0 && gameAreaSize.height > 0 else {
            print("⚠️ Invalid game area size: \(gameAreaSize)")
            return
        }
        
        // Create bubbles with safe margins
        bubbles = generateNonOverlappingBubbles(count: maxBubbles, in: gameAreaSize)
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            }
            
            var updatedBubbles = bubbles.map { bubble -> Bubble? in
                var b = bubble
                b.remainingTime -= 1
                return b.remainingTime > 0 ? b : nil
            }.compactMap { $0 }
            
            let countToAdd = maxBubbles - updatedBubbles.count
            if countToAdd > 0 && gameAreaSize != .zero {
                let newBubbles = generateNonOverlappingBubbles(count: countToAdd, in: gameAreaSize, existing: updatedBubbles)
                updatedBubbles += newBubbles
            }
            bubbles = updatedBubbles
            
            if remainingTime == 0 {
                timer?.invalidate()
                isGameOver = true
            }
        }
    }
    
    func generateNonOverlappingBubbles(count: Int, in size: CGSize, existing: [Bubble] = []) -> [Bubble] {
        var newBubbles: [Bubble] = []
        var attempts = 0
        let maxAttempts = 100
        
        // Add safety margin and ensure we have a valid size
        let safeWidth = max(size.width - 20, 100)
        let safeHeight = max(size.height - 20, 100)
        let margin: CGFloat = 10.0  // Increased margin for safety
        
        // Calculate max radius based on available area
        let maxRadius = min(safeWidth, safeHeight) / 10  // Limit max radius
        
        print("🔍 Generating bubbles: count=\(count), size=\(size), safeArea=\(safeWidth)x\(safeHeight)")
        
        while newBubbles.count < count && attempts < maxAttempts {
            attempts += 1
            
            // Use smaller bubbles to avoid overflow
            let color = BubbleColor.weightedRandom()
            let radius = CGFloat.random(in: 20...min(80, maxRadius))
            
            // Ensure bubbles stay within safe area with margin
            let x = CGFloat.random(in: (radius + margin)...(safeWidth - radius - margin))
            let y = CGFloat.random(in: (radius + margin)...(safeHeight - radius - margin))
            let position = CGPoint(x: x, y: y)
            
            let newBubble = Bubble(
                color: color,
                radius: radius,
                position: position,
                remainingTime: Int.random(in: 3...6)
            )
            
            // Extra safety check for bounds
            let isOutOfBounds = position.x - radius < margin ||
                               position.x + radius > safeWidth - margin ||
                               position.y - radius < margin ||
                               position.y + radius > safeHeight - margin
            
            if isOutOfBounds {
                print("⚠️ Bubble out of bounds: position=\(position), radius=\(radius)")
                continue
            }
            
            // Check for overlaps
            let isOverlapping = (existing + newBubbles).contains { b in
                let dx = b.position.x - newBubble.position.x
                let dy = b.position.y - newBubble.position.y
                let distance = sqrt(dx * dx + dy * dy)
                return distance < (b.radius + newBubble.radius)
            }
            
            if !isOverlapping {
                print("✅ Bubble added at \(position) with radius \(radius)")
                newBubbles.append(newBubble)
            }
        }
        
        print("📊 Generated \(newBubbles.count)/\(count) bubbles in \(attempts) attempts")
        return newBubbles
    }
}

// Helper to get the size of the game area
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
