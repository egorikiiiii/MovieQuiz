//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Егор Гончаров on 08.09.2025.
//

import Foundation

// Расширяем при объявлении
final class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            return GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    private var totalQuestionsAsked: Int {
        get {
            return storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    var totalAccuracy: Double {
        return totalQuestionsAsked == 0 ? 0 : Double(correctAnswers) / Double(totalQuestionsAsked) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        bestGame = newGameResult.isBetterThan(bestGame)
            ? newGameResult
            : bestGame
        correctAnswers += count
        totalQuestionsAsked += amount
    }
}
