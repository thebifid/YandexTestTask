//
//  MenuBarCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

class MenuBarCell: UICollectionViewCell {
    // MARK: - Public Properties

    override var isSelected: Bool {
        didSet {
            UIView.transition(with: self.label, duration: 0.1, options: .transitionCrossDissolve, animations: {
                self.label.font = self.isSelected ? .boldSystemFont(ofSize: self.fontSize) :
                    .boldSystemFont(ofSize: self.fontSize - 1)
                self.label.textColor = self.isSelected ? UIColor.black : .lightGray
            }, completion: nil)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? .black : .lightGray
        }
    }

    // MARK: - Private Properties

    private var fontSize: CGFloat = 18

    // MARK: - UI Controls

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.contentMode = .left
        return label
    }()

    // MARK: - UI Actions

    private func setupUI() {
        clipsToBounds = true
        addSubview(label)
        constrain(label) { label in
            label.left == label.superview!.left
            label.centerY == label.superview!.centerY
        }
    }

    // MARK: - Public Methods

    func setupCell(label: String, fontSize: CGFloat?) {
        self.label.text = label

        if let fontSize = fontSize {
            self.fontSize = fontSize
        }

        self.label.font = .boldSystemFont(ofSize: self.fontSize)
    }

    // MARK: - UI Actions

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        attributes.size.width = label.frame.width
        return attributes
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
