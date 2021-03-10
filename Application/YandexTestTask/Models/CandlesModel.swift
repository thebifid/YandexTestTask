//
//  CandlesModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

struct CandlesModel: Decodable {
    let o: [Double]?
    let h: [Double]?
    let l: [Double]?
    var c: [Double]?
    let v: [Int]?
    let t: [UInt]?
    let s: String
}
