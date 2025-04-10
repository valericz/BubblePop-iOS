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
    let date: Date
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
        self.date = Date()
    }
}

class HighScoreViewModel: ObservableObject {
    @Published var scores: [HighScoreEntry] = []
    private let maxScoresToKeep = 10
    private let scoresKey = "highScores"
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        guard let data = UserDefaults.standard.data(forKey: scoresKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            scores = try decoder.decode([HighScoreEntry].self, from: data)
            // Sort scores by highest first
            scores.sort { $0.score > $1.score }
        } catch {
            print("Error loading scores: \(error.localizedDescription)")
        }
    }
    
    func saveScore(name: String, score: Int) {
        // Add the new score
        let newEntry = HighScoreEntry(name: name, score: score)
        scores.append(newEntry)
        
        // Sort by highest score
        scores.sort { $0.score > $1.score }
        
        // Keep only the top scores
        if scores.count > maxScoresToKeep {
            scores = Array(scores.prefix(maxScoresToKeep))
        }
        
        // Save to UserDefaults
        saveToUserDefaults()
    }
    
    func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(scores)
            UserDefaults.standard.set(data, forKey: scoresKey)
        } catch {
            print("Error saving scores: \(error.localizedDescription)")
        }
    }
    
    func getHighestScore() -> Int {
        return scores.first?.score ?? 0
    }
    
    func clearAllScores() {
        scores = []
        UserDefaults.standard.removeObject(forKey: scoresKey)
    }
}
