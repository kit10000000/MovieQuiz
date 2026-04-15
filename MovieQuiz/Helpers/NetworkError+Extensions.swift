//
//  NetworkError+Extensions.swift
//  MovieQuiz
//
//  Created by Ekaterina on 15.04.2026.
//

import Foundation

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        }
    }
}
