//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Егор Гончаров on 06.09.2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    func loadData()
    func requestNextQuestion()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
