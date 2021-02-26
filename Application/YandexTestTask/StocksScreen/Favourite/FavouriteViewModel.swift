//
//  FavouriteViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 26.02.2021.
//

import CoreData
import Foundation
import UIKit

class FavouriteViewModel {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var favListInfo: [TrendingListFullInfoModel] = [] {
        didSet {
            didUpdateModel?()
        }
    }

    func fetchData() {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        let items = try? context.fetch(fetchRequest)

        items?.forEach { favListInfo.append(TrendingListFullInfoModel(stock: $0)) }
    }

    var didUpdateModel: (() -> Void)?
}
