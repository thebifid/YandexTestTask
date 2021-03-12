//
//  StockDetailViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 12.03.2021.
//

import Foundation

class StockDetailViewModel {
    let stockInfo: TrendingListFullInfoModel!

    var ticker: String {
        return stockInfo.ticker
    }

    var companyName: String {
        return stockInfo.name
    }

    init(stock: TrendingListFullInfoModel) {
        stockInfo = stock
    }
}
