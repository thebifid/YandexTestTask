//
//  AlertAssist.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 24.02.2021.
//

import UIKit

class AlertAssist {
    static func AlertWithCancel(withError error: Error) -> UIAlertController {
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        return ac
    }

    static func AlertWithTryAgainAction(withError error: Error, action: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: action)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(action)
        ac.addAction(cancelAction)
        return ac
    }
}
