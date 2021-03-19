//
//  IntervalButton.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 10.03.2021.
//

import UIKit

class IntervalButton: UIButton {
    var isActive: Bool = false {
        didSet {
            if isActive {
                backgroundColor = .black
                setTitleColor(.white, for: .normal)
            } else {
                backgroundColor = R.color.customLightGray()
                setTitleColor(.black, for: .normal)
            }
        }
    }

    // MARK: - UI Actions

    private func setupUI() {
        titleLabel?.font = R.font.montserratBold(size: 12)
        layer.cornerRadius = 12
    }

    // MARK: - Public Methods

    func configure(withTitle title: String, isActive: Bool = false) {
        setTitle(title, for: .normal)
        self.isActive = isActive
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
