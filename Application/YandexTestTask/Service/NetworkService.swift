//
//  NetworkService.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

class NetworkService {
    static let sharedInstance = NetworkService()

    func requestTrandingList(completion: @escaping (Result<ConstituentsModel, Error>) -> Void) {
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

                    self.requestCompanyProfile(tickers: first5)
                    self.requestCompanyQuote(tickers: first5)
                    completion(.success(constituents))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func requestCompanyProfile(tickers: [String]) {
        var companyProfiles = [String: CompanyProfileModel]()

        tickers.forEach { ticker in
            let url = BuildUrl(path: API.companyProfile, params: ["symbol": ticker])
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else { return }
                if let data = data {
                    do {
                        let profile = try JSONDecoder().decode(CompanyProfileModel.self, from: data)
                        companyProfiles[ticker] = profile
                        print(companyProfiles)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
    }

    private func requestCompanyQuote(tickers: [String]) {
        var companyQuotes = [String: CompanyQuoteModel]()
        tickers.forEach { ticker in
            let url = BuildUrl(path: API.companyQuote, params: ["symbol": ticker])
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else { return }
                if let data = data {
                    do {
                        let quote = try JSONDecoder().decode(CompanyQuoteModel.self, from: data)
                        companyQuotes[ticker] = quote
                        print(companyQuotes)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
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
