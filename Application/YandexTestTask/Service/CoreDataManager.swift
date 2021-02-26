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

    // reference to managed object context
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
            print(error)
        }

        return nil
    }

    func fetchFavs() -> [TrendingListFullInfoModel] {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        let items = try? context.fetch(fetchRequest)
        var result = [TrendingListFullInfoModel]()
        items?.forEach { result.append(TrendingListFullInfoModel(stock: $0)) }
        return result
    }

    func removeFromCoreData(byTicker ticker: String) {
        if let stockToDelete = fetchObject(byTicker: ticker) {
            context.delete(stockToDelete)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }

    func saveToFavCoreData(stockInfo: TrendingListFullInfoModel) {
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

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}
