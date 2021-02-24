//
//  AlertAssist.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 24.02.2021.
//

import UIKit

class AlertAssist {
    static func AlertWithAction(withError error: Error) -> UIAlertController {
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        return ac
    }
}
