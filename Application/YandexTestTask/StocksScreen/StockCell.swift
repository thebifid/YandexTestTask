//
//  StockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import SDWebImage
import UIKit

protocol StockCellDelegate: AnyObject {
    func favButtonTapped(cell: StockCell)
}

class StockCell: UITableViewCell {
    weak var delegate: StockCellDelegate?

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
        label.font = .boldSystemFont(ofSize: 12)
        label.text = "Apple Inc."
        label.numberOfLines = 2
        return label
    }()

    private lazy var addToFavButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fav", for: .normal)
        button.addTarget(self, action: #selector(buttonTappedHandler(sender:)), for: .touchUpInside)
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

    // MARK: - Selectors

    @objc private func buttonTappedHandler(sender: UIButton) {
        delegate?.favButtonTapped(cell: self)
    }

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
        companyInfoStackView.distribution = .equalCentering
        companyInfoStackView.spacing = 2

        let companyPriceInfoStackView = UIStackView(arrangedSubviews: [stockPriceLabel, dayChangeLabel])
        companyPriceInfoStackView.axis = .vertical
        companyPriceInfoStackView.spacing = 2
        companyPriceInfoStackView.alignment = .center
        companyPriceInfoStackView.distribution = .equalCentering

        addSubview(companyInfoStackView)
        constrain(companyInfoStackView, stockImageView) { companyInfoStackView, stockImageView in
            companyInfoStackView.left == stockImageView.right + 10
            companyInfoStackView.centerY == companyInfoStackView.superview!.centerY
            companyInfoStackView.width == companyInfoStackView.superview!.width / 2.4
        }

        addSubview(companyPriceInfoStackView)
        constrain(companyPriceInfoStackView, companyInfoStackView) { companyPriceInfoStackView, companyInfoStackView in
            companyPriceInfoStackView.left == companyInfoStackView.right + 10
            companyPriceInfoStackView.top == companyInfoStackView.top
            companyPriceInfoStackView.right == companyPriceInfoStackView.superview!.right - 20
        }

        constrain(addToFavButton) { addToFavButton in
            addToFavButton.height == 22
            addToFavButton.width == 40
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

        stockImageView.image = UIImage(data: companyInfo.logoData)
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = false
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
