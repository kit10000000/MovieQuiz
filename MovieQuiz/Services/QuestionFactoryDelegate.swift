//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ekaterina on 05.04.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
