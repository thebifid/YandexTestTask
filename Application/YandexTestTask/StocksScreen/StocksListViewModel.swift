//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

class StocksListViewModel {
    // MARK: - Private properties

    // MARK: - Public Properties

    var trendingListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateModel?()
        }
    }

    var favListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateFavs?()
        }
    }

    // MARK: - Handlers

    var didUpdateModel: (() -> Void)?
    var didUpdateFavs: (() -> Void)?

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

    func fetchData() {
        favListInfo = CoreDataManager.sharedInstance.fetchFavs()
    }

    func saveToFav(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if CoreDataManager.sharedInstance.checkIfExist(byTicker: trendingListInfo[index].ticker) == false {
            favListInfo.append(trendingListInfo[index])
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: trendingListInfo[index]) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    completion(.success(()))
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: trendingListInfo[index].ticker) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    completion(.success(()))
                }
            }
        }
    }
}
