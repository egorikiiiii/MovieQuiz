//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Егор Гончаров on 08.09.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        if self.total == 0 && another.total == 0 {
            return false
        } else if another.total == 0 {
            return true
        } else {
            return Double(self.correct) / Double(self.total) > Double(another.correct) / Double(another.total)
        }
    }
}
