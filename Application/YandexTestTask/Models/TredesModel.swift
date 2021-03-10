//
//  TredesModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

struct Trades: Decodable {
    let data: [PriceChange]
    let type: String

    init() {
        data = [PriceChange]()
        type = ""
    }
}

struct PriceChange: Decodable {
    let s: String
    let p: Double
    let t: UInt
    let v: Double
}
