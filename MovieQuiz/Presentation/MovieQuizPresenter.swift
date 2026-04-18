//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ekaterina on 18.04.2026.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageData: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func getCurrentQuestionIndex() -> Int{
        currentQuestionIndex
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let viewController = self.viewController else { return }
            
            viewController.statisticService.store(correct: correctAnswers, total: self.questionsAmount)

            let bestGame = viewController.statisticService.bestGame
            let text = """
                Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                Количество сыгранных квизов: \(viewController.statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", viewController.statisticService.totalAccuracy))%
                """
     
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            self.viewController?.show(quiz: viewModel)
        } else {
            self.viewController?.resetImageLayout()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
}

