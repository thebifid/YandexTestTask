//
//  CompanyProfileModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

struct CompanyProfileModel: Decodable {
    let country: String
    let currency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Float
    let name: String
    let phone: String
    let shareOutstanding: Float
    let ticker: String
    let weburl: String
}
