//
//  HeaderView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import Cartography
import UIKit

class HeaderView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        return label
    }()

    private func setupUI() {
        addSubview(label)
        constrain(label) { label in
            label.left == label.superview!.left + 20
            label.centerY == label.superview!.centerY
        }
    }

    init(withTitle title: String) {
        super.init(frame: .zero)
        setupUI()
        label.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
