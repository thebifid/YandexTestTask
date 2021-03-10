//
//  CompanyQuoteModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation

struct CompanyQuoteModel: Decodable {
    let c: Double
    let h: Double
    let l: Double
    let o: Double
    let pc: Double
    let t: Double

    init(stock: Stock) {
        c = stock.c
        h = stock.h
        l = stock.l
        o = stock.o
        pc = stock.pc
        t = stock.t
    }
}
