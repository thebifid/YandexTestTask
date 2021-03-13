//
//  StockDetailViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 12.03.2021.
//

import Foundation

class StockDetailViewModel {
    // MARK: - Public Properties

    let stockInfo: TrendingListFullInfoModel!

    var ticker: String {
        return stockInfo.ticker
    }

    var companyName: String {
        return stockInfo.name
    }

    var inFav: Bool {
        return CoreDataManager.sharedInstance.checkIfExist(byTicker: ticker)
    }

    // MARK: - Public Methods

    /// Action for fav button tapped in StoksScreen
    func stocksFavButtonTapped(completion: @escaping ((Result<Void, Error>) -> Void)) {
        if !CoreDataManager.sharedInstance.checkIfExist(byTicker: ticker) {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: stockInfo) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    completion(.success(()))
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: ticker) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Init

    init(stock: TrendingListFullInfoModel) {
        stockInfo = stock
    }
}
