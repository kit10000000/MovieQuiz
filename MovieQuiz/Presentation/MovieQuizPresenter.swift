//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ekaterina on 18.04.2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    // MARK: - Private Properties
    private let statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10

    // MARK: - Init
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }

    // MARK: - Methods
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func restartGame() {
        viewController?.resetImageLayout()
        resetQuestionIndex()
        resetCorrectAnswers()
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func reloadGame() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            didAnswer(isCorrectAnswer: true)
        }

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            viewController?.resetImageLayout()
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame

        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")

        return resultMessage
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageData: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    private func resetCorrectAnswers() {
        correctAnswers = 0
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
