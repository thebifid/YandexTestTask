//
//  StockDetailViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

class StockDetailViewModel: WebSocketConnectionDelegate {
    // MARK: - Private Properties

    private var stockInfo: TrendingListFullInfoModel!
    private var companyCandlesData: CandlesModel? {
        didSet {
            didUpdateCandles?()
        }
    }

    // MARK: - Handlers

    var didUpdateCandles: (() -> Void)?

    // MARK: - Public Properties

    var candles: [Double] {
        return companyCandlesData?.c ?? []
    }

    var openPrice: Double {
        return stockInfo.o
    }

    var currentPrice: Double {
        return stockInfo.c
    }

    var ticker: String {
        return stockInfo.ticker
    }

    var companyName: String {
        return stockInfo.name
    }

    // MARK: - Private Properties

    private var dayStartTimestamp: String {
        let date = Date()
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        return String(Int(startTime.timeIntervalSince1970))
    }

    private var weekBackTimestamp: String {
        return String(Int(Date().timeIntervalSince1970 - 604800))
    }

    private var monthBackTimestamp: String {
        return String(Int(Date().timeIntervalSince1970 - 2629743))
    }

    private var sixMonthBackTimestamp: String {
        return String(Int(Date().timeIntervalSince1970 - 15778458))
    }

    private var yearBackTimestamp: String {
        return String(Int(Date().timeIntervalSince1970 - 31556926))
    }

    private var currentTimestamp: String {
        return String(Int(Date().timeIntervalSince1970))
    }

    private(set) var activeInterval: IntevalTime = .month {
        didSet {
            requestCompanyCandles()
        }
    }

    // MARK: - Enums

    enum IntevalTime: Int {
        case day, week, month, sixMonths, year, all
    }

    // MARK: - Public Methods

    func setActiveInterval(withNewInterval interval: IntevalTime) {
        activeInterval = interval
    }

    func requestCompanyCandles() {
        var fromIntervalTime: String!
        var resolution: String!
        switch activeInterval {
        case .day:
            fromIntervalTime = dayStartTimestamp
            resolution = "1"
        case .week:
            fromIntervalTime = weekBackTimestamp
            resolution = "60"
        case .month:
            fromIntervalTime = monthBackTimestamp
            resolution = "240"
        case .sixMonths:
            fromIntervalTime = sixMonthBackTimestamp
            resolution = "D"
        case .year:
            fromIntervalTime = yearBackTimestamp
            resolution = "D"
        case .all:
            fromIntervalTime = "0"
            resolution = "M"
        }

        NetworkService.sharedInstance.requestCompanyCandle(withSymbol: ticker, resolution: resolution, from: fromIntervalTime,
                                                           to: currentTimestamp) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(candles):
                self.companyCandlesData = candles
            }
        }
    }

    // MARK: - WebSocket

    private var webSocketConnection: WebSocketConnection!

    func onConnected(connection: WebSocketConnection) {
        print("Connected")
    }

    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected")
    }

    func onError(connection: WebSocketConnection, error: Error) {
        print(error.localizedDescription)
    }

    func onMessage(connection: WebSocketConnection, text: String) {
        print(text)
    }

    func onMessage(connection: WebSocketConnection, data: Data) {
        print(data)
    }

    func connectWebSocket() {
        guard let url = URL(string: "wss://ws.finnhub.io?token=c0mgb5748v6ue78flnkg") else { return }
        webSocketConnection = WebSocketTaskConnection(url: url)
        webSocketConnection.delegate = self
        webSocketConnection.connect()
        webSocketConnection.send(text: "{\"type\":\"subscribe\",\"symbol\":\"\(ticker)\"}")
    }

    func disconnectWebSocket() {
        webSocketConnection.disconnect()
    }

    // MARK: - Init

    init(stockModel: TrendingListFullInfoModel) {
        stockInfo = stockModel
    }
}
