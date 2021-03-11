//
//  FavouriteListViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 11.03.2021.
//

import Foundation

class FavouriteListViewModel {
    // MARK: - Public Properties

    var favListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateFavsList?()
        }
    }

    // MARK: - Handlers

    var didUpdateFavsList: (() -> Void)?

    // MARK: - Public Methods

    /// Fetch data from CoreData
    func fetchData(completion: @escaping ((Result<Void, Error>) -> Void)) {
        CoreDataManager.sharedInstance.fetchFavs(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(info):
                self.updateQuotes(model: info) { [weak self] result in
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                    case let .success(model):
                        self?.favListInfo = model
                        completion(.success(()))
                    }
                }
            }

        })
    }

    /// Action for fav button tapped in StoksScreen
    func stocksFavButtonTapped(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if CoreDataManager.sharedInstance.checkIfExist(byTicker: favListInfo[index].ticker) == false {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: favListInfo[index]) { [weak self] result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.didUpdateFavsList?()
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: favListInfo[index].ticker) { [weak self] result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.didUpdateFavsList?()
                }
            }
        }
    }

    // MARK: - Private Methods

    private func updateQuotes(model: [TrendingListFullInfoModel],
                              completion: @escaping ((Result<[TrendingListFullInfoModel], Error>) -> Void)) {
        var info = model
        let tickers = info.map { $0.ticker }
        NetworkService.sharedInstance.requestCompanyQuote(tickers: tickers) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(quotes):
                for index in info.indices {
                    info[index].c = quotes[info[index].ticker]?.c ?? info[index].c
                    info[index].o = quotes[info[index].ticker]?.o ?? info[index].o
                }
                completion(.success(info))
            }
        }
    }
}
