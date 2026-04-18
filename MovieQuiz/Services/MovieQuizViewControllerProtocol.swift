//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ekaterina on 18.04.2026.
//


protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func resetImageLayout()
    
    func showNetworkError(message: String)
}
