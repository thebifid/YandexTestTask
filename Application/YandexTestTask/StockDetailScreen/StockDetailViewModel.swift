//
//  StockDetailViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

class StockDetailViewModel {
    private var stockInfo: TrendingListFullInfoModel!

    var ticker: String {
        return stockInfo.ticker
    }

    var companyName: String {
        return stockInfo.name
    }

    init(stockModel: TrendingListFullInfoModel) {
        stockInfo = stockModel
    }
}
