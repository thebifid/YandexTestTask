//
//  MenuBarCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

class MenuBarCell: UICollectionViewCell {
    // MARK: - UI Controls

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.baselineAdjustment = .alignCenters
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()

    // MARK: - UI Actions

    private func setupUI() {
        clipsToBounds = true
        addSubview(label)
        constrain(label) { label in
            label.left == label.superview!.left
            label.bottom == label.superview!.bottom
        }
    }

    // MARK: - Public Methods

    func setupCell(label: String) {
        self.label.text = label
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        UIView.animate(withDuration: 0.9) {
            attributes.size.width = self.label.frame.width
        }
        return attributes
    }

    override var isSelected: Bool {
        didSet {
            label.font = isSelected ? .boldSystemFont(ofSize: 30) : .boldSystemFont(ofSize: 25)
            label.textColor = isSelected ? .black : .lightGray
        }
    }

    override var isHighlighted: Bool {
        didSet {
            label.font = isHighlighted ? .boldSystemFont(ofSize: 30) : .boldSystemFont(ofSize: 25)
        }
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
