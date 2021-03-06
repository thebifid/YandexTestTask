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

    var popularList: [String]? {
        didSet {
            popularList = Array((popularList?.prefix(16)) ?? [])
            didUpdatePopularList?()
        }
    }

    var searchResult: [TrendingListFullInfoModel] = [] {
        didSet {
            didSearch?()
        }
    }

    var searchedList: [String]?

    // MARK: - Handlers

    var didUpdateModel: (() -> Void)?
    var didUpdateFavs: (() -> Void)?
    var didUpdatePopularList: (() -> Void)?
    var didSearch: (() -> Void)?

    // MARK: - Public Methods

    /// Request list of trending stoks
    func requestTrendingList(completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkService.sharedInstance.requestTrendingList { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(companies):
                self.popularList = companies.constituents
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

    func searchRequest(withText text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkService.sharedInstance.requestSearch(withText: text) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(answer):
                self?.searchResult = answer
                completion(.success(()))
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
                    let trendingListIndex = self.trendingListInfo.firstIndex(where: { $0.ticker == self.favListInfo[index].ticker })
                    if trendingListIndex != nil {
                        self.trendingListInfo[trendingListIndex!].inFav = false
                    }
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
                    let trendingListIndex = self.trendingListInfo.firstIndex(where: { $0.ticker == self.favListInfo[index].ticker })
                    if trendingListIndex != nil {
                        self.trendingListInfo[trendingListIndex!].inFav = true
                    }
                    completion(.success(()))
                }
            }
        }
    }
}
