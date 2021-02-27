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

    /// Request list of trending stoks
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

    /// Fetch data from CoreData
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

    /// Action for fav button tapped in StoksScreen
    func stocksFavButtonTapped(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if CoreDataManager.sharedInstance.checkIfExist(byTicker: trendingListInfo[index].ticker) == false {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: trendingListInfo[index]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.trendingListInfo[index].inFav = true
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
                        self.trendingListInfo[index].inFav = false
                    }
                    completion(.success(()))
                }
            }
        }
    }

    /// Action for fav button tapped in FavScreen
    func favsFavButtonTapped(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        let inFav = favListInfo[index].inFav

        if inFav {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: favListInfo[index].ticker) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.favListInfo[index].inFav = false
                    completion(.success(()))
                }
            }
        } else {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: favListInfo[index]) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.favListInfo[index].inFav = true
                    completion(.success(()))
                }
            }
        }
    }
}
