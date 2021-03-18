//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

protocol ViewModelWithSotcks {
    func coreDataDidChanges()
}

class StocksListViewModel: ViewModelWithSotcks {
    func coreDataDidChanges() {
        didUpdateStocksList?()
    }

    // MARK: - Public Properties

    var trendingListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateStocksList?()
        }
    }

    // MARK: - Handlers

    var didUpdateStocksList: (() -> Void)?

    // MARK: - Public Methods

    func requestTrendingList(completion: @escaping (Result<Void, NetworkMonitor.ConnectionStatus>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else {
            completion(.failure(.notConnected))
            return
        }
        NetworkService.sharedInstance.requestTrendingList { result in
            switch result {
            case let .failure(error):
                completion(.failure(.connected(error)))
            case let .success(companies):
                NetworkService.sharedInstance.requestCompaniesInfo(companies: companies.constituents) { result in
                    switch result {
                    case let .failure(error):
                        completion(.failure(.connected(error)))
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

    init() {
        CoreDataManager.sharedInstance.subscribeModelToCoreDataChanges(viewModel: self)
    }
}
