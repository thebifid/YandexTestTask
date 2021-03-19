//
//  BuyButton.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 13.03.2021.
//

import UIKit

class BuyButton: UIButton {
    // MARK: - UI Actions

    private func setupUI() {
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        titleLabel?.font = R.font.montserratBold(size: 16)
        layer.cornerRadius = 16
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }

    // MARK: - Public Methods

    func configure(withTitle title: String) {
        setTitle(title, for: .normal)
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
