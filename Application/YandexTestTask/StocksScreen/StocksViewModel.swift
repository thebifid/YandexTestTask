//
//  StocksViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

class StocksViewModel {
    // MARK: - Properties?

    var trendingListInfo = [TrendingListFullInfoModel]()

    // MARK: - Public Methods

    func requestTrendingList() {
        NetworkService.sharedInstance.requestTrandingList { result in

            switch result {
            case let .failure(error):
                break

            case let .success(info):
                print(info)
            }
        }
    }
}
