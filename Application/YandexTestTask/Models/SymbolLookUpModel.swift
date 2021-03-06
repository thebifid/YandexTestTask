//
//  SymbolLookUpModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 06.03.2021.
//

import Foundation

struct SymbolLookUpModel: Decodable {
    let count: Int
    let result: [SearchResDescription]
}

struct SearchResDescription: Decodable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
