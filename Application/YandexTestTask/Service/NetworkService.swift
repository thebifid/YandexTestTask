//
//  NetworkService.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation
import UIKit

class NetworkService {
    static let sharedInstance = NetworkService()

    func requestTrandingList(completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var companyQuotes = [String: CompanyQuoteModel]()
        var companyImages = [String: Data]()

        let url = BuildUrl(path: API.list, params: ["symbol": "^NDX"])
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else { return }
            if let data = data {
                do {
                    let constituents = try JSONDecoder().decode(ConstituentsModel.self, from: data)
                    print(constituents)
                    var first5 = [String]()

                    let hasImageDispatchGroup = DispatchGroup()
                    hasImageDispatchGroup.enter()
                    self.ifHasImage(tickers: constituents.constituents) { result in
                        switch result {
                        case let .success(imagesDataDitct):
                            for index in 1 ... 8 {
                                companyImages[Array(imagesDataDitct)[index].key] = Array(imagesDataDitct)[index].value
                                first5.append(Array(imagesDataDitct)[index].key)
                            }
                        case .failure:
                            break
                        }
                        hasImageDispatchGroup.leave()
                    }

                    ///

                    hasImageDispatchGroup.notify(queue: .main) {
                        let dispatchGroup = DispatchGroup()
                        dispatchGroup.enter()
                        self.requestCompanyProfile(tickers: first5) { result in
                            switch result {
                            case let .success(profiles):
                                companyProfiles = profiles
                            case let .failure(error):
                                print(error.localizedDescription)
                            }
                            dispatchGroup.leave()
                        }

                        dispatchGroup.enter()
                        self.requestCompanyQuote(tickers: first5) { result in
                            switch result {
                            case let .success(quotes):
                                companyQuotes = quotes

                            case let .failure(error):
                                print(error.localizedDescription)
                            }
                            dispatchGroup.leave()
                        }

                        dispatchGroup.notify(queue: .main) {
                            var trendingListFullInfo = [TrendingListFullInfoModel]()
                            companyProfiles.keys.forEach { key in
                                trendingListFullInfo.append(TrendingListFullInfoModel(companyProfile: companyProfiles[key]!,
                                                                                      companyQuote: companyQuotes[key]!, companyImageData: companyImages[key]!))
                            }
                            completion(.success(trendingListFullInfo))
                        }
                    }

                    ///
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func requestCompanyProfile(tickers: [String], completion: @escaping (Result<[String: CompanyProfileModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()

        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in
            dispatchGroup.enter()
            let url = BuildUrl(path: API.companyProfile, params: ["symbol": ticker])
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else { return }
                if let data = data {
                    do {
                        let profile = try JSONDecoder().decode(CompanyProfileModel.self, from: data)
                        companyProfiles[ticker] = profile
                        dispatchGroup.leave()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(companyProfiles))
        }
    }

    private func requestCompanyQuote(tickers: [String], completion: @escaping (Result<[String: CompanyQuoteModel], Error>) -> Void) {
        var companyQuotes = [String: CompanyQuoteModel]()

        let dispatchGroup = DispatchGroup()
        tickers.forEach { ticker in
            dispatchGroup.enter()
            let url = BuildUrl(path: API.companyQuote, params: ["symbol": ticker])
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else { return }
                if let data = data {
                    do {
                        let quote = try JSONDecoder().decode(CompanyQuoteModel.self, from: data)
                        companyQuotes[ticker] = quote
                        dispatchGroup.leave()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(companyQuotes))
        }
    }

    private func ifHasImage(tickers: [String], completion: @escaping (Result<[String: Data], Error>) -> Void) {
        var tickerDataDict = [String: Data]()
//
        let dispatchGroup = DispatchGroup()

        for index in 1 ... 15 {
            dispatchGroup.enter()
            let url = BuildUrl(path: API.logo, params: ["symbol": tickers[index]])
            URLSession.shared.dataTask(with: url) { data, _, _ in

                guard data != nil else { return }

                if UIImage(data: data!) != nil {
                    tickerDataDict[tickers[index]] = data
                }

                dispatchGroup.leave()
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            print(tickerDataDict)
            completion(.success(tickerDataDict))
        }
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
