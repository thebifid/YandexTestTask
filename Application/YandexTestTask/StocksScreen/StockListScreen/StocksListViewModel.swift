//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

class StocksListViewModel {
    // MARK: - Public Properties

    var trendingListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateStocksList?()
        }
    }

    // MARK: - Handlers

    var didUpdateStocksList: (() -> Void)?

    // MARK: - Public Methods

    func requestTrendingList(completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkService.sharedInstance.requestTrendingList { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(companies):
                NetworkService.sharedInstance.requestCompaniesInfo(companies: companies.constituents) { result in
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))

                    case let .success(info):
                        self.trendingListInfo = info
                        completion(.success(()))
                    }
                }
            }
        }
    }

    /// Action for fav button tapped in StoksScreen
    func stocksFavButtonTapped(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if !CoreDataManager.sharedInstance.checkIfExist(byTicker: trendingListInfo[index].ticker) {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: trendingListInfo[index]) { [weak self] result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.didUpdateStocksList?()
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: trendingListInfo[index].ticker) { [weak self] result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.didUpdateStocksList?()
                }
            }
        }
    }
}
