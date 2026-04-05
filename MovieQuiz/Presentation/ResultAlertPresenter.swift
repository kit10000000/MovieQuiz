//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Ekaterina on 05.04.2026.
//
import UIKit

final class ResultAlertPresenter {
    weak var delegate: ResultAlertPresenterDelegate?

    func show(in viewController: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.delegate?.didTapAlertButton()
        }

        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
