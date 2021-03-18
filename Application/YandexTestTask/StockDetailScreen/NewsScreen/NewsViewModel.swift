//
//  NewsViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 15.03.2021.
//

import Foundation

class NewsViewModel {
    // MARK: - Private Properties

    private let symbol: String!

    // MARK: - Public Properties

    var news = [NewsModel]() {
        didSet {
            didUpdateModel?()
        }
    }

    var currentDateString: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: date)
        return currentDateString
    }

    var weekAgoDateString: String {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sevenDaysAgoString = dateFormatter.string(from: sevenDaysAgo!)
        return sevenDaysAgoString
    }

    // MARK: - Handlers

    var didUpdateModel: (() -> Void)?

    // MARK: - Public Methods

    func requestCompanyNews(completion: @escaping (Result<Void, NetworkMonitor.ConnectionStatus>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else {
            completion(.failure(.notConnected))
            return
        }

        NetworkService.sharedInstance.requestCompanyNews(withSymbol: symbol,
                                                         from: weekAgoDateString, to: currentDateString) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(.connected(error)))
            case let .success(news):
                completion(.success(()))
                self?.news = news
            }
        }
    }

    // MARK: - Init

    init(symbol: String) {
        self.symbol = symbol
    }
}
