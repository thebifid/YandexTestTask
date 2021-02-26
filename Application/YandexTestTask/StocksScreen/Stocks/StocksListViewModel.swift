//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import CoreData
import Foundation
import UIKit

class StocksListViewModel {
    // MARK: - Private properties

    // reference to managed object context
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Public Properties

    var trendingListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateModel?()
        }
    }

    // MARK: - Handlers

    var didUpdateModel: (() -> Void)?

    // MARK: - Public Methods

    func requestTrendingList(completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkService.sharedInstance.requestTrandingList { result in

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(info):
                self.trendingListInfo = info
                completion(.success(()))
            }
        }
    }

    func saveToFav(index: Int) {
        let stockInfo = trendingListInfo[index]
        let newStock = Stock(context: context)

        newStock.country = stockInfo.country
        newStock.currency = stockInfo.currency
        newStock.exchange = stockInfo.exchange
        newStock.finnhubIndustry = stockInfo.finnhubIndustry
        newStock.ipo = stockInfo.ipo
        newStock.logo = stockInfo.logo
        newStock.marketCapitalization = stockInfo.marketCapitalization
        newStock.name = stockInfo.name
        newStock.phone = stockInfo.phone
        newStock.shareOutstanding = stockInfo.shareOutstanding
        newStock.ticker = stockInfo.ticker
        newStock.weburl = stockInfo.weburl

        newStock.c = stockInfo.c
        newStock.h = stockInfo.h
        newStock.l = stockInfo.l
        newStock.o = stockInfo.o
        newStock.pc = stockInfo.pc
        newStock.t = stockInfo.t

        newStock.logoData = stockInfo.logoData

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}
