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

    var searchedList: [String] {
        return UserDefaults.standard.object(forKey: "SavedTerms") as? [String] ?? []
    }

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

    enum StockScreen {
        case stocks, favourite, search
    }

    private func didUpdateAllModels() {
        didUpdateModel?()
        didUpdateFavs?()
        didSearch?()
    }

    /// Action for fav button tapped in StoksScreen
    func stocksFavButtonTapped(list: StockScreen, index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        var dataSource: [TrendingListFullInfoModel] = []

        switch list {
        case .stocks:
            dataSource = trendingListInfo
        case .favourite:
            dataSource = favListInfo
        case .search:
            dataSource = searchResult
        }

        if CoreDataManager.sharedInstance.checkIfExist(byTicker: dataSource[index].ticker) == false {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: dataSource[index]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    switch list {
                    case .stocks:
                        self.favListInfo.append(dataSource[index])
                        self.didUpdateAllModels()
                    case .favourite:
                        self.didUpdateAllModels()
                    case .search:
                        self.favListInfo.append(dataSource[index])
                        self.didUpdateAllModels()
                    }

                    completion(.success(()))
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: dataSource[index].ticker) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    switch list {
                    case .stocks:
                        self.favListInfo.removeAll(where: { $0.ticker == dataSource[index].ticker })
                        self.didUpdateAllModels()
                    case .favourite:
                        self.didUpdateAllModels()
                    case .search:
                        self.favListInfo.removeAll(where: { $0.ticker == dataSource[index].ticker })
                        self.didUpdateAllModels()
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

    func saveSerchRequestTerm(withTerm term: String) -> Bool {
        let defaults = UserDefaults.standard
        var savedTerms = defaults.object(forKey: "SavedTerms") as? [String] ?? []
        if !savedTerms.contains(term) {
            savedTerms.insert(term, at: 0)
            if savedTerms.count > 20 {
                savedTerms.removeLast()
            }
            defaults.setValue(savedTerms, forKey: "SavedTerms")
            return true
        }
        return false
    }
}
