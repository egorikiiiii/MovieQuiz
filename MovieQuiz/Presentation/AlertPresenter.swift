//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Егор Гончаров on 06.09.2025.
//

import UIKit

final class AlertPresenter {
    func renderAlert(viewController: UIViewController, alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
