//
//  NetworkService.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

class NetworkService {
    static let sharedInstance = NetworkService()

    func requestTrandingList(completion: @escaping (Result<[TrendingListFullInfoModel], Error>) -> Void) {
        var companyProfiles = [String: CompanyProfileModel]()
        var companyQuotes = [String: CompanyQuoteModel]()

        let url = BuildUrl(path: API.list, params: ["symbol": "^NDX"])
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else { return }
            if let data = data {
                do {
                    let constituents = try JSONDecoder().decode(ConstituentsModel.self, from: data)

                    var first5 = [String]()
                    for index in 1 ... 5 {
                        first5.append(constituents.constituents[index])
                    }

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
                                                                                  companyQuote: companyQuotes[key]!))
                        }
                        completion(.success(trendingListFullInfo))
                    }
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
