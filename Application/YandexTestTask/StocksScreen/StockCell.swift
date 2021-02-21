//
//  StockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import SDWebImage
import UIKit

class StockCell: UITableViewCell {
    // MARK: - Private Properties

    // MARK: - UI Controls

    private let stockImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
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

    private let addToFavButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Star", for: .normal)
        return button
    }()

    private let stockPriceLabel: UILabel = {
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

        let nameLabelFavButtonStackView = UIStackView(arrangedSubviews: [tickerLabel, addToFavButton, UIView()])
        nameLabelFavButtonStackView.distribution = .fill
        nameLabelFavButtonStackView.spacing = 5

        let companyInfoStackView = UIStackView(arrangedSubviews: [nameLabelFavButtonStackView, complanyNameLabel])
        companyInfoStackView.axis = .vertical
        companyInfoStackView.spacing = 2

        addSubview(companyInfoStackView)
        constrain(companyInfoStackView, stockImageView) { stackView, image in
            stackView.centerY == image.centerY
            stackView.left == image.right + 20
            stackView.right == stackView.superview!.right - 100 //!
        }

        let companyPriceInfoStackView = UIStackView(arrangedSubviews: [stockPriceLabel, dayChangeLabel])
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

    func setupCell(color: UIColor, companyInfo: TrendingListFullInfoModel) {
        backgroundColor = color

        tickerLabel.text = companyInfo.ticker
        complanyNameLabel.text = companyInfo.name
        stockPriceLabel.text = "$\(companyInfo.c)" // Смотреть валюту!

        print(companyInfo.logo)
        if let url = URL(string: companyInfo.logo) {
            stockImageView.sd_setImage(with: url, completed: nil)
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
