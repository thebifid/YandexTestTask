//
//  MetricsViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import Foundation

class MetricsViewModel {
    // MARK: - Private Properties

    private let stockInfo: TrendingListFullInfoModel!

    private var metrics: Metric? {
        didSet {
            metricsData = metricsToArray(metric: metrics!)
            didUpdateModel?()
        }
    }

    // MARK: - Public Properties

    var symbol: String {
        return stockInfo.ticker
    }

    var currency: String {
        return stockInfo.currency
    }

    var sectionTitles: [String] {
        return ["Financial indicators", "Cost estimation", "Profitability", "Dividends", "Trade"]
    }

    var metricsData = [[String]]()

    // Названия не приходят из API, поэтому хардкод
    var metricsTitles = [
        [
            "Market Cap",
            "Free operating cash flow revenue"
        ],

        [
            "P/E",
            "P/S",
            "EPS",
            "Grow EPS",
            "Revenue grow"
        ],

        [
            "ROE",
            "ROA",
            "Debt/Equity",
            "Net Profit Margin"
        ],

        [
            "Payout ratio",
            "Current dividend yield",
            "Dividend yield"
        ],

        [
            "Open price",
            "Close price",
            "52 w High",
            "52 w Low",
            "10 Day average trading volume",
            "3 Month average trading volume",
            "beta"
        ]
    ]

    // Та же причина
    var metricsSubtitles = [
        [
            "Company value",
            ""
        ],

        [
            "Stock price / profit",
            "Stock price / revenue",
            "Earnings per stock",
            "Average growth over 5 years",
            "Average growth over 5 years"
        ],

        [
            "Return on capital",
            "Return on assets",
            "",
            "Profit as a % of revenue"
        ],

        [
            "Percentage of dividends from profit",
            "For 5 years",
            "Annual"
        ],

        [
            "",
            "",
            "",
            "",
            "Average for 10 days",
            "average for 3 months",
            "stock market volatility"
        ]
    ]

    // MARK: - Handlers

    var didUpdateModel: (() -> Void)?

    // MARK: - Public Methods

    func requestCompanyMetrics(completion: @escaping (Result<Void, NetworkMonitor.ConnectionStatus>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else {
            completion(.failure(.notConnected))
            return
        }

        NetworkService.sharedInstance.requestCompanyMetrics(withSymbol: symbol) { result in
            switch result {
            case let .failure(error):
                if self.metricsData.isEmpty {
                    completion(.failure(.connected(error)))
                }
            case let .success(metrics):
                completion(.success(()))
                self.metrics = metrics.metric
            }
        }
    }

    // MARK: - Private Methods

    private func metricsToArray(metric: Metric) -> [[String]] {
        guard let metrics = self.metrics else { return [[]] }
        return [
            [
                String(roundValue(value: stockInfo.marketCapitalization / 1000)).addSignToEnd(currency: "USD", extraWord: "B"),
                String(roundValue(value: metrics._freeOperatingCashFlowRevenue5Y ?? 0)).addPercent()
            ],

            [
                String(roundValue(value: metrics.peNormalizedAnnual ?? 0)),
                String(roundValue(value: metrics.psAnnual ?? 0)),
                String(roundValue(value: metrics.epsInclExtraItemsTTM ?? 0)).addSignToEnd(currency: "USD"),
                String(roundValue(value: metrics.epsGrowth5Y ?? 0)).addPercent(),
                String(roundValue(value: metrics.revenueGrowth5Y ?? 0)).addPercent()
            ],

            [
                String(roundValue(value: metrics.roaeTTM ?? 0)),
                String(roundValue(value: metrics.roaRfy ?? 0)),
                String(roundValue(value: metrics._totalDebtTotalEquityAnnyal ?? 0)).addPercent(),
                String(roundValue(value: metrics.netProfitMargin5Y ?? 0)).addPercent()
            ],

            [
                String(roundValue(value: metrics.payoutRatioAnnual ?? 0)).addPercent(),
                String(roundValue(value: metrics.currentDividendYieldTTM ?? 0)).addPercent(),
                String(roundValue(value: metrics.dividendYield5Y ?? 0)).addPercent()
            ],

            [
                String(stockInfo.o).addSignToEnd(currency: currency),
                String(stockInfo.pc).addSignToEnd(currency: currency),
                String(roundValue(value: metrics._52WeekHigh ?? 0)).addSignToEnd(currency: currency),
                String(roundValue(value: metrics._52WeekLow ?? 0)).addSignToEnd(currency: currency),
                String(roundValue(value: (metrics._10DayAverageTradingVolume ?? 0) / 10)).addSignToEnd(currency: "USD", extraWord: "B"),
                String(roundValue(value: (metrics._3MonthAverageTradingVolume ?? 0) / 10)).addSignToEnd(currency: "USD", extraWord: "B"),
                String(roundValue(value: metrics.beta ?? 0))
            ]
        ]
    }

    private func roundValue(value: Double) -> Double {
        return round(100 * value) / 100
    }

    // MARK: - Init

    init(stockInfo: TrendingListFullInfoModel) {
        self.stockInfo = stockInfo
    }
}
