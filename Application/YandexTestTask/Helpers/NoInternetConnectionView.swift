//
//  NoInternetConnectionView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.03.2021.
//

import Cartography
import UIKit

class NoInternetConnectionView: UIView {
    private var actionHander: (() -> Void)?

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "Error receiving data, check your internet connection"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let refreshButton: RefreshButton = {
        let button = RefreshButton()
        button.addTarget(self, action: #selector(doAction), for: .touchUpInside)
        return button
    }()

    @objc private func doAction() {
        actionHander?()
    }

    private func setupUI() {
        addSubview(errorLabel)
        constrain(errorLabel) { errorLabel in
            errorLabel.top == errorLabel.superview!.top
            errorLabel.centerX == errorLabel.superview!.centerX
            errorLabel.width == errorLabel.superview!.width
        }

        addSubview(refreshButton)
        constrain(refreshButton, errorLabel) { refreshButton, _ in
            refreshButton.bottom == refreshButton.superview!.bottom
            refreshButton.centerX == refreshButton.superview!.centerX
            refreshButton.width == refreshButton.superview!.width / 2
            refreshButton.height == 30
        }
    }

    init(withAction action: @escaping (() -> Void)) {
        super.init(frame: .zero)
        actionHander = action
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
