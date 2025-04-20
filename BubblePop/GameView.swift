import SwiftUI

struct GameView: View {
    @State var timer: Timer?
    @State private var bubbles: [Bubble] = []
    @State private var remainingTime: Int
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var lastPoppedColor: BubbleColor?
    @State private var showGameOver = false
    @State private var gameAreaSize: CGSize = .zero
    @State private var isViewAppeared = false
    @State private var resetCount = 0 // Add a counter for force resets
    @State private var isPaused = false // Track if game is paused
    @State private var isSystemPaused = false // Track if pause was caused by system
    @State private var currentFingerPosition: CGPoint = .zero
    @State private var isFingerOnScreen: Bool = false
    @State private var animatingBubbleID: UUID? = nil
    @State private var animationPhase: Int = 0 // 0: none, 1: shrink, 2: expand+fade
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var navigationState: NavigationState
    
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
            // Header with score and buttons
            HStack {
                // Home button
                Button(action: {
                    // Signal to return to root view
                    navigationState.returnToRoot = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "house.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                }
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                // Pause button
                Button(action: {
                    togglePause()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding(.horizontal)
            
            Text("Hello, \(playerName)!")
                .font(.title2)
            
            Text("Time Left: \(remainingTime) seconds")
                .font(.title3)
                .padding(.bottom)
            
            // Game area with fixed aspect ratio
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if isGameOver { return }
                                        
                                        // Update finger position
                                        currentFingerPosition = value.location
                                        isFingerOnScreen = true
                                        
                                        // Check if any bubbles are touched
                                        checkForBubbleTouch()
                                    }
                                    .onEnded { _ in
                                        isFingerOnScreen = false
                                    }
                            )
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
                        Image(bubble.color.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                            .position(bubble.position)
                            .onTapGesture {
                                
                                burstBubble(bubble)}
                    }
                }
                
                // Pause overlay
                if isPaused {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("GAME PAUSED")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        if isSystemPaused {
                            Text("App was interrupted")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                        }
                        
                        Button(action: {
                            isSystemPaused = false
                            togglePause()
                        }) {
                            Text("Resume")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Return to home screen
                            navigationState.returnToRoot = true
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Main Menu")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.red)
                                .cornerRadius(10)
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
        .fullScreenCover(isPresented: $isGameOver, onDismiss: {
            // When returning from GameOverView, reset the game
            print("🔄 GameOverView dismissed, resetting game")
            resetGame(forceReset: true)
        }) {
            GameOverView(playerName: playerName, score: score)
                .environmentObject(navigationState)
        }
        .onChange(of: navigationState.returnToRoot) { newValue in
            if newValue {
                // If we need to return to root, dismiss this view
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetGame"))) { _ in
            resetGame(forceReset: true)
        }
        // Add this handler for app state changes
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    

    private func checkForBubbleTouch() {
        guard isFingerOnScreen else { return }
        
        // Create a local copy to avoid modifying the array while iterating
        var bubblesRemaining = bubbles
        var bubblesToRemove: [UUID] = []
        
        for bubble in bubblesRemaining {
            let distance = hypot(bubble.position.x - currentFingerPosition.x,
                                bubble.position.y - currentFingerPosition.y)
            
            // If finger is within bubble radius, burst it
            if distance <= bubble.radius {
                bubblesToRemove.append(bubble.id)
                burstBubble(bubble)
            }
        }
    }

    // Add this function to handle the bursting logic
    private func burstBubble(_ bubble: Bubble) {
        if isGameOver { return }
        
        // Remove this bubble
        bubbles.removeAll { $0.id == bubble.id }
        
        // Calculate score
        let gainedScore: Int
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            gainedScore = Int(ceil(Double(bubble.baseScore) * 1.5))
        } else {
            gainedScore = bubble.baseScore
        }
        
        score += gainedScore
        lastPoppedColor = bubble.color
        
        // Add a new bubble
        let newBubbles = generateNonOverlappingBubbles(count: 1, in: gameAreaSize, existing: bubbles)
        bubbles += newBubbles
    }
    
    // New method to handle scene phase changes
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        print("📱 Scene phase changed to: \(newPhase)")
        
        if newPhase == .active {
            // App becomes active again
            if isSystemPaused {
                // Don't automatically resume - let user manually resume
                print("🔄 App returning to foreground, staying paused")
            }
        } else if newPhase == .inactive || newPhase == .background {
            // App goes to background or becomes inactive
            if !isPaused && !isGameOver {
                print("⏸️ Auto-pausing game due to app state change")
                isSystemPaused = true
                isPaused = true
                stopGame()
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        
        if isPaused {
            // Pause the game
            timer?.invalidate()
            timer = nil
        } else {
            // Resume the game
            startTimer()
        }
    }
    
    private func startTimer() {
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
                showGameOver = true
            }
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
        showGameOver = false
        isPaused = false
        isSystemPaused = false
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
        startTimer()
    }
    
    // Rest of your code remains the same
    // ...
}
    
    func generateNonOverlappingBubbles(count: Int, in size: CGSize, existing: [Bubble] = []) -> [Bubble] {
        // Original bubble generation code remains the same
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


// Helper to get the size of the game area
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
