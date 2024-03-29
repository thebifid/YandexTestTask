//
//  NetworkService.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import EasyStash
import Foundation
import os.log
import UIKit

class NetworkService {
    static let sharedInstance = NetworkService()

    /// Request companies info needed to display stock cell (image, like ticker, name, price)
    /// В эту функцию передаётся список тикеров, проверяется есть ли у тикера логотип
    /// (В API сервиса не у всех тикеров есть картинка, к сожалению)
    /// Далее, у тех тикеров, что имеют логотип запрашивается информация,
    /// необходмая для отображения ячейки ( requestCompanyProfile() и requestCompanyQuote() )
    /// Когда вся информация загружена вызывается completion
    /// Вся информация, кроме актуальных цен кешируется
    /// Чтобы не превышать лимит запросов API, я искусственно ограничиваю количество
    /// Акций на главном экране
    func requestCompaniesInfo(companies: [String], completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var companyQuotes = [String: CompanyQuoteModel]()
        var companyImages = [String: Data]()
        var isAnyError: Error?

        var first12 = [String]()
        let hasImageDispatchGroup = DispatchGroup()
        hasImageDispatchGroup.enter()
        ifHasImage(tickers: companies) { result in
            switch result {
            case let .success(imagesDataDitct):
                for index in 0 ..< min(imagesDataDitct.count, 12) {
                    companyImages[Array(imagesDataDitct)[index].key] = Array(imagesDataDitct)[index].value
                    first12.append(Array(imagesDataDitct)[index].key)
                }
            case let .failure(error):
                completion(.failure(error))
            }
            hasImageDispatchGroup.leave()
        }

        hasImageDispatchGroup.notify(queue: .global(qos: .background)) {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.requestCompanyProfile(tickers: first12) { result in
                switch result {
                case let .success(profiles):
                    companyProfiles = profiles
                case let .failure(error):
                    isAnyError = error
                }
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            self.requestCompanyQuote(tickers: first12) { result in
                switch result {
                case let .success(quotes):
                    companyQuotes = quotes
                case let .failure(error):
                    isAnyError = error
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                var trendingListFullInfo = [TrendingListFullInfoModel]()
                guard isAnyError == nil else {
                    completion(.failure(isAnyError!))
                    return
                }
                companyProfiles.keys.forEach { key in
                    trendingListFullInfo.append(TrendingListFullInfoModel(companyProfile: companyProfiles[key]!,
                                                                          companyQuote: companyQuotes[key]!,
                                                                          companyImageData: companyImages[key]!))
                }
                completion(.success(trendingListFullInfo))
            }
        }
    }

    func requestCompaniesInfoEvenWithoutImage(companies: [String],
                                              completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var companyQuotes = [String: CompanyQuoteModel]()
        var companyImages = [String: Data]()
        var isAnyError: Error?

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        requestCompanyProfile(tickers: companies) { result in
            switch result {
            case let .success(profiles):
                companyProfiles = profiles
            case let .failure(error):
                isAnyError = error
            }
            dispatchGroup.leave()

            dispatchGroup.enter()
            self.requestCompanyQuote(tickers: companies) { result in
                switch result {
                case let .success(quotes):
                    companyQuotes = quotes
                case let .failure(error):
                    isAnyError = error
                }
                dispatchGroup.leave()
            }

            companies.forEach { company in
                dispatchGroup.enter()
                let url = self.buildUrl(path: API.logo, params: ["symbol": company])
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if error != nil {
                        isAnyError = error
                        return
                    }
                    if let data = data {
                        if UIImage(data: data) != nil {
                            companyImages[company] = data
                        }
                    }
                    dispatchGroup.leave()
                }.resume()
            }

            dispatchGroup.notify(queue: .main) {
                var trendingListFullInfo = [TrendingListFullInfoModel]()
                guard isAnyError == nil else {
                    completion(.failure(isAnyError!))
                    return
                }
                companyProfiles.keys.forEach { key in
                    trendingListFullInfo.append(TrendingListFullInfoModel(companyProfile: companyProfiles[key]!,
                                                                          companyQuote: companyQuotes[key]!,
                                                                          companyImageData: companyImages[key]))
                }
                completion(.success(trendingListFullInfo))
            }
        }
    }

    /// Эта функция возвращает список, необходимый для отображения акций на начальном экране, в данном случае
    /// Я использовал список Nasdaq 100 ( ^NDX)
    /// Так же используется при поиске для заполнения поля с Popular Requests
    func requestTrendingList(completion: @escaping (Result<ConstituentsModel, Error>) -> Void) {
        let url = buildUrl(path: API.list, params: ["symbol": "^NDX"])
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let constituents = try JSONDecoder().decode(ConstituentsModel.self, from: data)
                    completion(.success(constituents))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    /// Request company name, exhange, etc (Information about company)
    private func requestCompanyProfile(tickers: [String], completion: @escaping (Result<[String: CompanyProfileModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var isAnyError: Error?
        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in
            let url = buildUrl(path: API.companyProfile, params: ["symbol": ticker])
            if CacheManager.sharedInstance.exists(forKey: "\(ticker)Profile") {
                let profile = CacheManager.sharedInstance.loadCache(forKey: "\(ticker)Profile", as: CompanyProfileModel.self)
                companyProfiles[ticker] = profile
                return
            }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    completion(.failure(error!))
                    dispatchGroup.leave()
                    return
                }
                if let data = data {
                    do {
                        let profile = try JSONDecoder().decode(CompanyProfileModel.self, from: data)
                        companyProfiles[ticker] = profile
                        CacheManager.sharedInstance.saveCache(object: profile, forKey: "\(ticker)Profile")
                    } catch {
                        isAnyError = error
                    }
                }
                dispatchGroup.leave()
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            if isAnyError != nil {
                completion(.failure(isAnyError!))
            } else {
                completion(.success(companyProfiles))
            }
        }
    }

    /// Request company open price, current price, previous close price, etc
    func requestCompanyQuote(tickers: [String], completion: @escaping (Result<[String: CompanyQuoteModel], Error>) -> Void) {
        var companyQuotes = [String: CompanyQuoteModel]()
        var isAnyError: Error?
        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in
            dispatchGroup.enter()
            let url = buildUrl(path: API.companyQuote, params: ["symbol": ticker])
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    completion(.failure(error!))
                    dispatchGroup.leave()
                    return
                }
                if let data = data {
                    do {
                        let quote = try JSONDecoder().decode(CompanyQuoteModel.self, from: data)
                        companyQuotes[ticker] = quote
                    } catch {
                        isAnyError = error
                    }
                    dispatchGroup.leave()
                }
            }.resume()
        }
        dispatchGroup.notify(queue: .main) {
            if isAnyError != nil {
                completion(.failure(isAnyError!))
            } else {
                completion(.success(companyQuotes))
            }
        }
    }

    /// Check if company has logo
    private func ifHasImage(tickers: [String], completion: @escaping (Result<[String: Data], Error>) -> Void) {
        var tickerDataDict = [String: Data]()
        let dispatchGroup = DispatchGroup()

        let first24 = tickers.prefix(24)
        first24.forEach { ticker in
            let url = buildUrl(path: API.logo, params: ["symbol": ticker])
            guard !CacheManager.sharedInstance.exists(forKey: "\(ticker)NilImageData") else { return }
            if CacheManager.sharedInstance.exists(forKey: "\(ticker)ImageData") {
                let data = CacheManager.sharedInstance.loadCache(forKey: "\(ticker)ImageData", as: Data.self)
                tickerDataDict[ticker] = data
                return
            }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard data != nil else { return }
                if UIImage(data: data!) != nil {
                    tickerDataDict[ticker] = data
                    CacheManager.sharedInstance.saveCache(object: data, forKey: "\(ticker)ImageData")
                } else {
                    CacheManager.sharedInstance.saveBoolValue(value: true, forKey: "\(ticker)NilImageData")
                }

                dispatchGroup.leave()
            }.resume()
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(tickerDataDict))
        }
    }

    /// Uses when user search (ticker or company name)
    func requestSearch(withText text: String, completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        let url = buildUrl(path: API.search, params: ["q": text])
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            if let data = data {
                do {
                    let answer = try JSONDecoder().decode(SymbolLookUpModel.self, from: data)
                    var tickers = [String]()
                    answer.result.forEach { if $0.type == "Common Stock", !$0.symbol.contains(".") { tickers.append($0.symbol) } }

                    self.requestCompaniesInfoEvenWithoutImage(companies: tickers) { result in
                        switch result {
                        case let .failure(error):
                            completion(.failure(error))
                        case let .success(info):
                            completion(.success(info))
                        }
                    }

                } catch {
                    completion(.failure(error))
                }
            }

        }.resume()
    }

    /// Request for company candles data
    /// Эта функция нужна для построения графика акции, можно задать нужный интервал (за день, неделю и тд)
    func requestCompanyCandle(withSymbol symbol: String, resolution: String, from: String, to: String, interval: String,
                              completion: @escaping (Result<CandlesModel, Error>) -> Void) {
        if let candles = CacheManager.sharedInstance.loadCache(forKey: "\(symbol)Candles\(interval)",
                                                               as: CandlesModel.self, withExpiry: .maxAge(maxAge: 300)) {
            completion(.success(candles))
            return
        }

        let url = buildUrl(path: API.candle, params: ["symbol": symbol, "resolution": resolution, "from": from, "to": to])
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completion(.failure(error!))
                return
            }

            if let data = data {
                do {
                    let candles = try JSONDecoder().decode(CandlesModel.self, from: data)
                    if candles.s != "ok" {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: candles.s])
                        completion(.failure(error))
                        return
                    }

                    CacheManager.sharedInstance.saveCache(object: candles, forKey: "\(symbol)Candles\(interval)")

                    completion(.success(candles))
                } catch {
                    completion(.failure(error))
                }
            }

        }.resume()
    }

    func requestCompanyNews(withSymbol symbol: String, from: String, to: String,
                            completion: @escaping (Result<[NewsModel], Error>) -> Void) {
        let url = buildUrl(path: API.news, params: ["symbol": symbol, "from": from, "to": to])

        if let news = CacheManager.sharedInstance.loadCache(forKey: "\(symbol)News",
                                                            as: [NewsModel].self, withExpiry: .maxAge(maxAge: 86400)) {
            completion(.success(news))
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            if error != nil {
                completion(.failure(error!))
                return
            }

            if let data = data {
                do {
                    let news = try JSONDecoder().decode([NewsModel].self, from: data)
                    CacheManager.sharedInstance.saveCache(object: news, forKey: "\(symbol)News")
                    completion(.success(news))
                } catch {
                    completion(.failure(error))
                }
            }

        }.resume()
    }

    /// Информация для отображения финансовых показателей акции (Капитализация, P/E, P/S и тд)
    func requestCompanyMetrics(withSymbol symbol: String, completion: @escaping (Result<MetricsModel, Error>) -> Void) {
        let url = buildUrl(path: API.metrics, params: ["symbol": symbol, "metric": "all"])

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let metrics = CacheManager.sharedInstance.loadCache(forKey: "\(symbol)Metrics",
                                                                   as: MetricsModel.self, withExpiry: .maxAge(maxAge: 86400)) {
                completion(.success(metrics))
            }

            if error != nil {
                completion(.failure(error!))
                return
            }

            if let data = data {
                do {
                    let model = try JSONDecoder().decode(MetricsModel.self, from: data)
                    CacheManager.sharedInstance.saveCache(object: model, forKey: "\(symbol)Metrics")
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }

        }.resume()
    }

    /// Build url from API struct and params
    private func buildUrl(path: String, params: [String: String]) -> URL {
        var components = URLComponents()

        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems?.append(URLQueryItem(name: "token", value: API.token))

        return components.url!
    }
}
