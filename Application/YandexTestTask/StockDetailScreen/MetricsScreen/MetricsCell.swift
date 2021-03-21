//
//  MetricsCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.03.2021.
//

import Cartography
import UIKit

class MetricsCell: UITableViewCell {
    // MARK: - UI Controls

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratBold(size: 16)
        label.numberOfLines = 0
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratMedium(size: 16)
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = R.font.montserratMedium(size: 14)
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.customLightGray()
        return view
    }()

    // MARK: - UI Actions

    private func setupUI() {
        addSubview(titleLabel)

        addSubview(valueLabel)
        constrain(valueLabel) { valueLabel in
            valueLabel.top == valueLabel.superview!.top + 15
            valueLabel.right == valueLabel.superview!.right - 20
        }

        constrain(titleLabel) { titleLabel in
            titleLabel.top == titleLabel.superview!.top + 15
            titleLabel.left == titleLabel.superview!.left + 20
            titleLabel.width == titleLabel.superview!.width / 1.4
        }

        addSubview(subTitleLabel)
        constrain(subTitleLabel, titleLabel) { subTitleLabel, titleLabel in
            subTitleLabel.top == titleLabel.bottom + 10
            subTitleLabel.left == subTitleLabel.superview!.left + 20
        }

        addSubview(separatorView)
        constrain(separatorView, subTitleLabel) { separatorView, subTitleLabel in
            separatorView.top == subTitleLabel.bottom + 5
            separatorView.left == separatorView.superview!.left + 20
            separatorView.right == separatorView.superview!.right
            separatorView.height == 1
            separatorView.bottom == separatorView.superview!.bottom
        }
    }

    // MARK: - Public Methods

    func configure(withTitle title: String, subtitle: String, value: String) {
        titleLabel.text = title
        subTitleLabel.text = subtitle

        if value == "0.0" {
            valueLabel.text = "-"
        } else {
            valueLabel.text = value
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
