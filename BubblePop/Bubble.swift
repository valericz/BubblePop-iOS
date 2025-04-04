//
//  Bubble.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 1/4/2025.
//

import SwiftUI

enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black

    var point: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }

    var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
    
}

struct Bubble: Identifiable {
    let id = UUID()
    let color: BubbleColor
    let radius: CGFloat
    let position: CGPoint
    var remainingTime: Int

    var baseScore: Int {
        return color.point
    }
}
extension BubbleColor {
    static func weightedRandom() -> BubbleColor {
        let pool: [BubbleColor] = Array(repeating: .red, count: 40) +
                                  Array(repeating: .pink, count: 30) +
                                  Array(repeating: .green, count: 15) +
                                  Array(repeating: .blue, count: 10) +
                                  Array(repeating: .black, count: 5)
        return pool.randomElement()!
    }
}

