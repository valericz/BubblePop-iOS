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
    var playerName: String
    var gameTime: Int
    var maxBubbles: Int

    init(playerName: String, gameTime: Int, maxBubbles: Int) {
        self.playerName = playerName
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        _remainingTime = State(initialValue: gameTime)
    }

    var body: some View {
        VStack {
            Text("Hello, \(playerName)!")
                .font(.largeTitle)
                .padding()

            Text("Your current score is: \(score)")
                .padding()

            Text("Time Left: \(remainingTime) seconds")
                .padding()

            ZStack {
                // 1️⃣ Invisible background to capture final geometry
                Color.clear
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    gameAreaSize = geo.size
                                }
                        }
                    )

                // 2️⃣ Only render bubbles if gameAreaSize is valid
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

                            // 💥 Create one more bubble
                            let newBubbles = generateNonOverlappingBubbles(count: 1, in: gameAreaSize, existing: bubbles)
                            bubbles += newBubbles
                        }
                }
            }
            .onChange(of: gameAreaSize) { newSize in
                if bubbles.isEmpty && newSize != .zero {
                    bubbles = generateNonOverlappingBubbles(count: maxBubbles, in: newSize)

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
                        let newBubbles = generateNonOverlappingBubbles(count: countToAdd, in: newSize, existing: updatedBubbles)
                        bubbles = updatedBubbles + newBubbles

                        if remainingTime == 0 {
                            timer?.invalidate()
                            isGameOver = true
                            showGameOver = true
                        }
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isGameOver) {
            GameOverView(playerName: playerName, score: score)
        }
    }

    // ✅ Safe and updated bubble generator
    func generateNonOverlappingBubbles(count: Int, in size: CGSize, existing: [Bubble] = []) -> [Bubble] {
        var newBubbles: [Bubble] = []
        var attempts = 0

        while newBubbles.count < count && attempts < 100 {
            attempts += 1

            let color = BubbleColor.weightedRandom()
            let radius = CGFloat.random(in: 20...60) // Be reasonable
            let x = CGFloat.random(in: radius...(size.width - radius))
            let y = CGFloat.random(in: radius...(size.height - radius))
            let position = CGPoint(x: x, y: y)

            let newBubble = Bubble(
                color: color,
                radius: radius,
                position: position,
                remainingTime: Int.random(in: 3...6)
            )

            let isOverlapping = (existing + newBubbles).contains { b in
                let dx = b.position.x - newBubble.position.x
                let dy = b.position.y - newBubble.position.y
                let distance = sqrt(dx * dx + dy * dy)
                return distance < (b.radius + newBubble.radius)
            }

            if !isOverlapping {
                newBubbles.append(newBubble)
            }
        }

        return newBubbles
    }
}
