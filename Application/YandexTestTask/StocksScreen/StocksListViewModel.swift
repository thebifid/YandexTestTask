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

    func fetchData(completion: @escaping ((Result<Void, Error>) -> Void)) {
        CoreDataManager.sharedInstance.fetchFavs(completion: { [weak self] result in

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(info):
                self?.favListInfo = info
                completion(.success(()))
            }

        })
    }

    func saveToFav(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if CoreDataManager.sharedInstance.checkIfExist(byTicker: trendingListInfo[index].ticker) == false {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: trendingListInfo[index]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.favListInfo.append(self.trendingListInfo[index])
                    completion(.success(()))
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: trendingListInfo[index].ticker) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    if let indexToDelete = self.favListInfo.firstIndex(where: { $0.ticker == self.trendingListInfo[index].ticker }) {
                        self.favListInfo.remove(at: indexToDelete)
                    }
                    completion(.success(()))
                }
            }
        }
    }
}
