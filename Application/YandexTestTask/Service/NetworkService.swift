//
//  NetworkService.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import EasyStash
import Foundation
import UIKit

class NetworkService {
    static let sharedInstance = NetworkService()

    func requestCompaniesInfo(companies: [String], completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var companyQuotes = [String: CompanyQuoteModel]()
        var companyImages = [String: Data]()
        var isAnyError: Error?

        var first5 = [String]()
        let hasImageDispatchGroup = DispatchGroup()
        hasImageDispatchGroup.enter()
        ifHasImage(tickers: companies) { result in
            switch result {
            case let .success(imagesDataDitct):
                for index in 0 ..< min(imagesDataDitct.count, 5) {
                    companyImages[Array(imagesDataDitct)[index].key] = Array(imagesDataDitct)[index].value
                    first5.append(Array(imagesDataDitct)[index].key)
                }
            case let .failure(error):
                completion(.failure(error))
            }
            hasImageDispatchGroup.leave()
        }

        hasImageDispatchGroup.notify(queue: .global(qos: .background)) {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.requestCompanyProfile(tickers: first5) { result in
                switch result {
                case let .success(profiles):
                    companyProfiles = profiles
                case let .failure(error):
                    isAnyError = error
                }
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            self.requestCompanyQuote(tickers: first5) { result in
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

    func requestTrendingList(completion: @escaping (Result<ConstituentsModel, Error>) -> Void) {
        let url = BuildUrl(path: API.list, params: ["symbol": "^NDX"])
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

    private func requestCompanyProfile(tickers: [String], completion: @escaping (Result<[String: CompanyProfileModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var isAnyError: Error?

        var storage: Storage?
        var options: Options = Options()
        options.folder = "Cache"
        do {
            try storage = Storage(options: options)
        } catch {
            print(error.localizedDescription)
        }

        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in

            let url = BuildUrl(path: API.companyProfile, params: ["symbol": ticker])

            if storage != nil {
                if storage!.exists(forKey: "\(ticker)Profile") {
                    do {
                        let profile = try storage!.load(forKey: "\(ticker)Profile", as: CompanyProfileModel.self)
                        companyProfiles[ticker] = profile
                        return
                    } catch {}
                }
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
                        if storage != nil {
                            do {
                                try storage!.save(object: profile, forKey: "\(ticker)Profile")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }

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

    func requestCompanyQuote(tickers: [String], completion: @escaping (Result<[String: CompanyQuoteModel], Error>) -> Void) {
        var companyQuotes = [String: CompanyQuoteModel]()
        var isAnyError: Error?
        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in
            dispatchGroup.enter()
            let url = BuildUrl(path: API.companyQuote, params: ["symbol": ticker])
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

    private func ifHasImage(tickers: [String], completion: @escaping (Result<[String: Data], Error>) -> Void) {
        var tickerDataDict = [String: Data]()
        let dispatchGroup = DispatchGroup()
        var storage: Storage?
        var options = Options()
        options.folder = "Cache"

        do {
            try storage = Storage(options: options)
        } catch {
            print(error.localizedDescription)
        }

        let first15 = tickers.prefix(25)

        first15.forEach { ticker in
            let url = BuildUrl(path: API.logo, params: ["symbol": ticker])

            if storage != nil {
                guard !storage!.exists(forKey: "\(ticker)NilImageData") else { return }
                if storage!.exists(forKey: "\(ticker)ImageData") {
                    do {
                        let data = try storage!.load(forKey: "\(ticker)ImageData", as: Data.self)
                        tickerDataDict[ticker] = data
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard data != nil else { return }
                if UIImage(data: data!) != nil {
                    tickerDataDict[ticker] = data
                    if storage != nil {
                        do {
                            try storage!.save(object: data, forKey: "\(ticker)ImageData")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    try? storage!.save(object: true, forKey: "\(ticker)NilImageData")
                }

                dispatchGroup.leave()
            }.resume()
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(tickerDataDict))
        }
    }

    func requestSearch(withText text: String, completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        let url = BuildUrl(path: API.search, params: ["q": text])
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

                    self.requestCompaniesInfo(companies: tickers) { result in
                        switch result {
                        case let .failure(error):
                            print(error)

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

    func requestCompanyCandle(withSymbol symbol: String, resolution: String, from: String, to: String,
                              completion: @escaping (Result<CandlesModel, Error>) -> Void) {
        let url = BuildUrl(path: API.candle, params: ["symbol": symbol, "resolution": resolution, "from": from, "to": to])
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
                        print(error)
                        completion(.failure(error))
                        return
                    }
                    completion(.success(candles))
                } catch {
                    completion(.failure(error))
                }
            }

        }.resume()
    }

    private func BuildUrl(path: String, params: [String: String]) -> URL {
        var components = URLComponents()

        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems?.append(URLQueryItem(name: "token", value: API.token))

        return components.url!
    }
}
