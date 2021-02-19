//
//  MenuBarCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

class MenuBarCell: UICollectionViewCell {
    // MARK: - Private Properties

    private var selectedFontSize: CGFloat = 0
    private var deselectedFontSize: CGFloat = 0

    // MARK: - UI Controls

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
//        label.font = .boldSystemFont(ofSize: 20)
        label.contentMode = .center
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

    func setupCell(label: String, selectedFontSize: CGFloat, deselectedFontSize: CGFloat) {
        self.label.text = label
        self.label.font = .boldSystemFont(ofSize: deselectedFontSize)
        self.selectedFontSize = selectedFontSize
        self.deselectedFontSize = deselectedFontSize
    }

    // MARK: - UI Actions

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        attributes.size.width = label.frame.width
        return attributes
    }

    override var isSelected: Bool {
        didSet {
            UIView.transition(with: self.label, duration: 0.1, options: .transitionFlipFromTop, animations: {
                self.label.font = self.isSelected ? .boldSystemFont(ofSize: self.selectedFontSize) :
                    .boldSystemFont(ofSize: self.deselectedFontSize)
                self.label.textColor = self.isSelected ? UIColor.black : .lightGray
            }, completion: nil)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? .black : .lightGray
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
