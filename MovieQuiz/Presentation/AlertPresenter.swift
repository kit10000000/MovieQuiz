//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Ekaterina on 05.04.2026.
//
import UIKit

final class AlertPresenter {
    func show(in viewController: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alert.addAction(action)

        viewController.present(alert, animated: true, completion: nil)
    }
}
