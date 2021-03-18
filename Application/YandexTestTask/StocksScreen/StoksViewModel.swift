//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 11.03.2021.
//

import Foundation

class StocksViewModel {
    // MARK: - Public Properties

    var popularList = [String]() {
        didSet {
            didUpdatePopularList?()
        }
    }

    var searchResult: [TrendingListFullInfoModel] = []
    var searchedList: [String] {
        return UserDefaults.standard.object(forKey: "SavedTerms") as? [String] ?? []
    }

    // MARK: - Handlers

    var didUpdatePopularList: (() -> Void)?
    var didFavButtonClicked: (() -> Void)?

    // MARK: - Public Methods

    /// Request list of trending stoks
    func requestTrendingList(completion: @escaping (Result<Void, Error>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else { return }
        NetworkService.sharedInstance.requestTrendingList { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(list):
                let first18 = Array(list.constituents.prefix(18))
                self.popularList = first18
            }
        }
    }

    /// Action for fav button tapped in StoksScreen
    func stockFavButtonTapped(index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if CoreDataManager.sharedInstance.checkIfExist(byTicker: searchResult[index].ticker) == false {
            CoreDataManager.sharedInstance.saveToFavCoreData(stockInfo: searchResult[index]) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.didFavButtonClicked?()
                }
            }
        } else {
            CoreDataManager.sharedInstance.removeFromCoreData(byTicker: searchResult[index].ticker) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self.didFavButtonClicked?()
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
