//
//  CandlesModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

struct CandlesModel: Decodable {
    let o: [Float]?
    let h: [Float]?
    let l: [Float]?
    let c: [Float]?
    let v: [Int]?
    let t: [UInt]?
    let s: String
}
