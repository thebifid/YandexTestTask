//
//  RefreshButton.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.03.2021.
//

import UIKit

class RefreshButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = R.color.refreshHighlighted()
                }

            } else {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = .white
                }
            }
        }
    }

    private func setupUI() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 6
        titleLabel?.font = R.font.montserratMedium(size: 14)
        setTitle("Refresh", for: .normal)
        setTitleColor(.gray, for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
