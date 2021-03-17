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
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private func setupUI() {
        backgroundColor = .white
        addSubview(label)
        constrain(label) { label in
            label.left == label.superview!.left + 20
            label.bottom == label.superview!.bottom
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
