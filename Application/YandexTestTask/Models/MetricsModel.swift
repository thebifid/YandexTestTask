//
//  MetricsModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import Foundation

struct MetricsModel: Codable {
    let metric: Metric
}

struct Metric: Codable {
    // Financial indicators
    let marketCapitalization: Double?
    let _freeOperatingCashFlowRevenue5Y: Double?

    // cost estimation
    let peNormalizedAnnual: Double?
    let psAnnual: Double?
    let epsInclExtraItemsTTM: Double?
    let epsGrowth5Y: Double?
    let revenueGrowth5Y: Double?

    // Profitability

    let roaeTTM: Double?
    let roaRfy: Double?
    let _totalDebtTotalEquityAnnyal: Double?
    let netProfitMargin5Y: Double?

    // Dividends
    let payoutRatioAnnual: Double?
    let dividendYield5Y: Double?
    let currentDividendYieldTTM: Double?

    // Trade
    let _52WeekHigh: Double?
    let _52WeekLow: Double?
    let _10DayAverageTradingVolume: Double?
    let _3MonthAverageTradingVolume: Double?
    let beta: Double?

    enum CodingKeys: String, CodingKey {
        case marketCapitalization, peNormalizedAnnual, psAnnual, epsInclExtraItemsTTM, epsGrowth5Y, revenueGrowth5Y,
            roaeTTM, roaRfy, netProfitMargin5Y, payoutRatioAnnual, dividendYield5Y, currentDividendYieldTTM, beta

        case _freeOperatingCashFlowRevenue5Y = "freeOperatingCashFlow/revenue5Y"
        case _10DayAverageTradingVolume = "10DayAverageTradingVolume"
        case _totalDebtTotalEquityAnnyal = "totalDebt/totalEquityAnnual"
        case _52WeekHigh = "52WeekHigh"
        case _52WeekLow = "52WeekLow"
        case _3MonthAverageTradingVolume = "3MonthAverageTradingVolume"
    }
}
