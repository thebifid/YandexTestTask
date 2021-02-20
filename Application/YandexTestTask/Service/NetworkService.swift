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
        let url = BuildUrl(path: "1", params: ["symbol": "^NDX"])

        print(url)

        URLSession.shared.dataTask(with: url) { data, _, error in

            guard error == nil else { return }

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

    private func BuildUrl(path: String, params: [String: String]) -> URL {
        var components = URLComponents()

        components.scheme = API.scheme
        components.host = API.host
        components.path = API.list
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems?.append(URLQueryItem(name: "token", value: API.token))

        return components.url!
    }
}
