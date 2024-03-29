//
//  StockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import UIKit

protocol StockCellDelegate: AnyObject {
    func favButtonTapped(cell: StockCell)
}

class StockCell: UITableViewCell {
    // MARK: - Public Properties

    weak var delegate: StockCellDelegate?

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
        label.font = R.font.montserratBold(size: 18)
        label.text = "AAPL"
        return label
    }()

    private let complanyNameLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratMedium(size: 12)
        label.text = "Apple Inc."
        label.numberOfLines = 2
        return label
    }()

    private lazy var addToFavButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.star(), for: .normal)
        button.addTarget(self, action: #selector(buttonTappedHandler(sender:)), for: .touchUpInside)
        return button
    }()

    private let stockPriceLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratBold(size: 18)
        return label
    }()

    private let dayChangeLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratMedium(size: 12)
        label.textColor = R.color.customGreen()
        label.text = "+0.12 (1,15%)"
        return label
    }()

    // MARK: - Private Properties

    private var cellBackgroundColor: UIColor = .white

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
        companyInfoStackView.spacing = 5

        let companyPriceInfoStackView = UIStackView(arrangedSubviews: [stockPriceLabel, dayChangeLabel])
        companyPriceInfoStackView.axis = .vertical
        companyPriceInfoStackView.spacing = 5
        companyPriceInfoStackView.alignment = .trailing

        addSubview(companyInfoStackView)
        constrain(companyInfoStackView, stockImageView) { companyInfoStackView, stockImageView in
            companyInfoStackView.left == stockImageView.right + 10
            companyInfoStackView.centerY == companyInfoStackView.superview!.centerY
            companyInfoStackView.width == companyInfoStackView.superview!.width / 2.4
        }

        addSubview(companyPriceInfoStackView)
        constrain(companyPriceInfoStackView, companyInfoStackView) { companyPriceInfoStackView, _ in
            companyPriceInfoStackView.right == companyPriceInfoStackView.superview!.right - 20
            companyPriceInfoStackView.centerY == companyPriceInfoStackView.superview!.centerY
        }

        constrain(addToFavButton, stockPriceLabel) { addToFavButton, stockPriceLabel in
            addToFavButton.height == 17
            addToFavButton.width == addToFavButton.height
            stockPriceLabel.height == addToFavButton.height
        }
    }

    // MARK: - Public Methods

    func setupCell(color: UIColor, companyInfo: TrendingListFullInfoModel) {
        cellBackgroundColor = color

        addToFavButton.tintColor = CoreDataManager.sharedInstance.checkIfExist(byTicker: companyInfo.ticker) ?
            R.color.customYellow() : R.color.uncheckColor()

        tickerLabel.text = companyInfo.ticker
        complanyNameLabel.text = companyInfo.name

        stockPriceLabel.text = "\(round(100 * companyInfo.c) / 100)".withCurrency(currency: companyInfo.currency)

        dayChangeLabel.attributedText = Calculate.calculateDailyChange(currency: companyInfo.currency,
                                                                       currentPrice: companyInfo.c, previousClose: companyInfo.pc)

        if companyInfo.logoData != nil {
            stockImageView.image = UIImage(data: companyInfo.logoData!)
        } else {
            stockImageView.image = R.image.noImage()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .white
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted == true {
            backgroundColor = R.color.selectColor()
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }

        } else {
            backgroundColor = cellBackgroundColor
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        setHighlighted(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.setHighlighted(false, animated: true)
        }
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
