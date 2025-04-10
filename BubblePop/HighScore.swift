//
//  PlayerScore.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 9/4/2025.
//

import Foundation

struct HighScore: Identifiable,Codable{
    var id = UUID()
    let playerName: String
    var score: Int
    let date: Date
}
