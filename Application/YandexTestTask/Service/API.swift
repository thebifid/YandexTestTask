//
//  API.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

/// Struct with API paths, allows build URL
struct API {
    static let scheme = "https"
    static let host = "finnhub.io"
    static let list = "/api/v1/index/constituents"
    static let companyProfile = "/api/v1/stock/profile2"
    static let companyQuote = "/api/v1/quote"
    static let logo = "/api/logo"
    static let search = "/api/v1/search"
    static let candle = "/api/v1/stock/candle"
    static let news = "/api/v1/company-news"
    static let metrics = "/api/v1/stock/metric"

    static let token = "c0mgb5748v6ue78flnkg"
}
