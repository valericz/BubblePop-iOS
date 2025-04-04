//
//  HighScoreViewModel.swift
//  BubblePop
//
//  Created by WEIHUA ZHANG on 2/4/2025.
//

import Foundation

struct HighScoreEntry: Identifiable, Codable {
    let id = UUID()
    let name: String
    let score: Int
}
class HighScoreViewModel: ObservableObject {
    @Published var scores: [HighScoreEntry] = []
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        // 从文件或 UserDefaults 中读取历史分数
    }
    
    func saveScore(name: String, score: Int) {
        scores.append(HighScoreEntry(name: name, score: score))
        scores.sort { $0.score > $1.score }
        
        if scores.count > 10 {
            scores = Array(scores.prefix(10)) // 保留前 10 名
        }
        // 保存当前分数，并更新排行榜
    }
}
