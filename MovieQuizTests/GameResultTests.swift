//
//  GameResultTests.swift
//  MovieQuizTests
//
//  Created by Ekaterina on 18.04.2026.
//

import XCTest
@testable import MovieQuiz

final class GameResultTests: XCTestCase {
    func testGameResultIsBetterThanReturnsTrue() {
        // Given
        let betterResult = GameResult(correct: 8, total: 10, date: Date())
        let worseResult = GameResult(correct: 5, total: 10, date: Date())

        // When
        let result = betterResult.isBetterThan(worseResult)

        // Then
        XCTAssertTrue(result)
    }

    func testGameResultIsBetterThanReturnsFalse() {
        // Given
        let worseResult = GameResult(correct: 3, total: 10, date: Date())
        let betterResult = GameResult(correct: 7, total: 10, date: Date())

        // When
        let result = worseResult.isBetterThan(betterResult)

        // Then
        XCTAssertFalse(result)
    }

    func testGameResultIsBetterThanWithEqualResultsReturnsFalse() {
        // Given
        let firstResult = GameResult(correct: 5, total: 10, date: Date())
        let secondResult = GameResult(correct: 5, total: 10, date: Date())

        // When
        let result = firstResult.isBetterThan(secondResult)

        // Then
        XCTAssertFalse(result)
    }
}
