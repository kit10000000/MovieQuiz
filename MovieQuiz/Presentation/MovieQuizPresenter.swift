//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ekaterina on 18.04.2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    // MARK: - Properties
    let questionsAmount: Int = 10
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?

    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?

    // MARK: - Init
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
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

    func showNextQuestionOrResults() {
        if isLastQuestion() {
            guard let viewController else { return }

            viewController.statisticService.store(correct: correctAnswers, total: questionsAmount)

            let bestGame = viewController.statisticService.bestGame
            let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(viewController.statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", viewController.statisticService.totalAccuracy))%
                """

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController.show(quiz: viewModel)
        } else {
            viewController?.resetImageLayout()
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
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

    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
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
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
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
