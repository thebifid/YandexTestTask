//
//  NoInternetConnectionView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.03.2021.
//

import Cartography
import UIKit

class NoInternetConnectionView: UIView {
    private let noICLabel: UILabel = {
        let label = UILabel()
        label.text = "No internet connection"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label

    }()

    private func setupUI() {
        backgroundColor = R.color.customLightRed()
        addSubview(noICLabel)
        constrain(noICLabel) { noICLabel in
            noICLabel.bottom == noICLabel.superview!.bottom
            noICLabel.centerX == noICLabel.superview!.centerX
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
