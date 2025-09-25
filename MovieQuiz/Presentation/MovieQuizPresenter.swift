//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Егор Гончаров on 22.09.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Properties
    
    private let statisticService: StatisticServiceProtocol
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewControllerProtocol?
    
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func loadData() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += isCorrectAnswer ? 1 : 0
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.showAnswerResult(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let quizResults = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть еще раз"
            )
            viewController?.show(quiz: quizResults)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
