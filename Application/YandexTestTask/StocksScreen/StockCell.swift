//
//  StockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import UIKit

class StockCell: UITableViewCell {
    // MARK: - Private Properties

    // MARK: - UI Controls

    private let stockImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .green
        iv.layer.cornerRadius = 10
        return iv
    }()

    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "AAPL"
        return label
    }()

    private let complanyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 11)
        label.text = "Apple Inc."
        return label
    }()

    private let stockPrice: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "$300.93"
        return label
    }()

    private let dayChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = R.color.customGreen()
        label.text = "+0.12 (1,15%)"
        return label
    }()

    // MARK: - UI Actions

    private func setupUI() {
        layer.cornerRadius = 25
        addSubview(stockImageView)
        constrain(stockImageView) { stockImageView in
            stockImageView.centerY == stockImageView.superview!.centerY
            stockImageView.left == stockImageView.superview!.left + 20
            stockImageView.height == 60
            stockImageView.width == stockImageView.height
        }

        let companyInfoStackView = UIStackView(arrangedSubviews: [tickerLabel, complanyNameLabel])
        companyInfoStackView.axis = .vertical
        companyInfoStackView.spacing = 2

        addSubview(companyInfoStackView)
        constrain(companyInfoStackView, stockImageView) { stackView, image in
            stackView.centerY == image.centerY
            stackView.left == image.right + 20
        }

        let companyPriceInfoStackView = UIStackView(arrangedSubviews: [stockPrice, dayChangeLabel])
        companyPriceInfoStackView.axis = .vertical
        companyPriceInfoStackView.spacing = 2
        companyPriceInfoStackView.alignment = .center

        addSubview(companyPriceInfoStackView)
        constrain(companyPriceInfoStackView) { stackView in
            stackView.centerY == stackView.superview!.centerY
            stackView.right == stackView.superview!.right - 20
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .white
    }

    // MARK: - Public Methods

    func setupCell(color: UIColor) {
        backgroundColor = color
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
