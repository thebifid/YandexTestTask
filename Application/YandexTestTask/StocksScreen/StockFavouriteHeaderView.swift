//
//  StockFavouriteHeaderView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

class StockFavouriteHeaderView: UIView {
    // MARK: - UI Controls

    private let stocksButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stocks", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 35)
        return button
    }()

    private let favouriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Favourite", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 25)
        return button
    }()

    // MARK: - UI Actions

    private func setupUI() {
        backgroundColor = .white

        addSubview(stocksButton)
        constrain(stocksButton) { stocksButton in
            stocksButton.bottom == stocksButton.superview!.bottom
            stocksButton.left == stocksButton.superview!.left + 20
        }

        addSubview(favouriteButton)
        constrain(favouriteButton, stocksButton) { favouriteButton, stocksButton in
            favouriteButton.bottom == favouriteButton.superview!.bottom
            favouriteButton.left == stocksButton.right + 20
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
