//
//  CoreDataManager.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 26.02.2021.
//

import CoreData
import UIKit

class CoreDataManager {
    private init() {}

    static let sharedInstance = CoreDataManager()
    private var modelsWithStocks: [ViewModelWithSotcks] = []
    func subscribeModelToCoreDataChanges(viewModel: ViewModelWithSotcks) {
        modelsWithStocks.append(viewModel)
    }

    private func notifyViewModels() {
        modelsWithStocks.forEach { $0.coreDataDidChanges() }
    }

    // reference to managed object context
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    /// Check if object exist in CoreData
    func checkIfExist(byTicker ticker: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
        let predicate = NSPredicate(format: "ticker == %@", ticker)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let count = try context.count(for: request)
            return count != 0
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }

    /// Get object by ticker
    func fetchObject(byTicker ticker: String) -> Stock? {
        let request = NSFetchRequest<Stock>(entityName: "Stock")
        let predicate = NSPredicate(format: "ticker == %@", ticker)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let item = try context.fetch(request)
            if let info = item.first {
                return info
            }
        } catch {
            print(error) //!
        }

        return nil
    }

    /// Fetch list of Favourite stokcs
    func fetchFavs(completion: @escaping ((Result<[TrendingListFullInfoModel], Error>) -> Void)) {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            var result = [TrendingListFullInfoModel]()
            items.forEach { result.append(TrendingListFullInfoModel(stock: $0)) }

            completion(.success(result))

        } catch {
            completion(.failure(error))
        }
    }

    /// Remove object from CoreData by ticker
    func removeFromCoreData(byTicker ticker: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        if let stockToDelete = fetchObject(byTicker: ticker) {
            context.delete(stockToDelete)
            (UIApplication.shared.delegate as! AppDelegate).saveContext { [weak self] result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.notifyViewModels()
                    completion(.success(()))
                }
            }
        }
    }

    /// Save object to CoreData
    func saveToFavCoreData(stockInfo: TrendingListFullInfoModel, completion: @escaping ((Result<Void, Error>) -> Void)) {
        guard checkIfExist(byTicker: stockInfo.ticker) == false else { return }

        let newStock = Stock(context: context)

        newStock.country = stockInfo.country
        newStock.currency = stockInfo.currency
        newStock.exchange = stockInfo.exchange
        newStock.finnhubIndustry = stockInfo.finnhubIndustry
        newStock.ipo = stockInfo.ipo
        newStock.logo = stockInfo.logo
        newStock.marketCapitalization = stockInfo.marketCapitalization
        newStock.name = stockInfo.name
        newStock.phone = stockInfo.phone
        newStock.shareOutstanding = stockInfo.shareOutstanding
        newStock.ticker = stockInfo.ticker
        newStock.weburl = stockInfo.weburl

        newStock.c = stockInfo.c
        newStock.h = stockInfo.h
        newStock.l = stockInfo.l
        newStock.o = stockInfo.o
        newStock.pc = stockInfo.pc
        newStock.t = stockInfo.t

        newStock.logoData = stockInfo.logoData

        (UIApplication.shared.delegate as! AppDelegate).saveContext { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case .success:
                self?.notifyViewModels()
                completion(.success(()))
            }
        }
    }
}
