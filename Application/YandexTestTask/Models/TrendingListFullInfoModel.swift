//
//  TrendingListFullInfoModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Foundation
import UIKit

struct TrendingListFullInfoModel {
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

    let c: Float
    let h: Float
    let l: Float
    let o: Float
    let pc: Float
    let t: Float

    let logoData: Data

    init(companyProfile: CompanyProfileModel, companyQuote: CompanyQuoteModel, companyImageData: Data) {
        country = companyProfile.country
        currency = companyProfile.currency
        exchange = companyProfile.exchange
        finnhubIndustry = companyProfile.finnhubIndustry
        ipo = companyProfile.ipo
        logo = companyProfile.logo
        marketCapitalization = companyProfile.marketCapitalization
        name = companyProfile.name
        phone = companyProfile.phone
        shareOutstanding = companyProfile.shareOutstanding
        ticker = companyProfile.ticker
        weburl = companyProfile.weburl

        c = companyQuote.c
        h = companyQuote.h
        l = companyQuote.l
        o = companyQuote.o
        pc = companyQuote.pc
        t = companyQuote.t

        logoData = companyImageData
    }
}
