//
//  NewsModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 15.03.2021.
//

import Foundation

struct NewsModel: Codable {
    let category: String
    let datetime: Double
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
