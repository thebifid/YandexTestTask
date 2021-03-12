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

    var previousClose: Double {
        if activeInterval == .day {
            return stockInfo.pc
        } else {
            return (companyCandlesData?.c?.first)! //!
        }
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

    private(set) var activeInterval: IntevalTime = .day {
        didSet {
            requestCompanyCandles()
        }
    }

    // MARK: - Enums

    enum IntevalTime: Int {
        case day, week, month, sixMonths, year, all
    }

    // MARK: - Public Methods

    private var weekCompanyCandles: CandlesModel?
    private var monthCompanyCandles: CandlesModel?
    private var sixMonthCompanyCandles: CandlesModel?
    private var yearCompanyCandles: CandlesModel?
    private var allCompanyCadles: CandlesModel?

    func setActiveInterval(withNewInterval interval: IntevalTime) {
        activeInterval = interval
    }

    func requestCompanyCandles() {
        var fromIntervalTime: String!
        var resolution: String!
        switch activeInterval {
        case .day:
            fromIntervalTime = dayStartTimestamp
            resolution = "5"
        case .week:
            if weekCompanyCandles != nil {
                companyCandlesData = weekCompanyCandles
                return
            }
            fromIntervalTime = weekBackTimestamp
            resolution = "60"
        case .month:
            if monthCompanyCandles != nil {
                companyCandlesData = monthCompanyCandles
                return
            }
            fromIntervalTime = monthBackTimestamp
            resolution = "240"
        case .sixMonths:
            if sixMonthCompanyCandles != nil {
                companyCandlesData = sixMonthCompanyCandles
                return
            }
            fromIntervalTime = sixMonthBackTimestamp
            resolution = "D"
        case .year:
            if yearCompanyCandles != nil {
                companyCandlesData = yearCompanyCandles
                return
            }
            fromIntervalTime = yearBackTimestamp
            resolution = "D"
        case .all:
            if allCompanyCadles != nil {
                companyCandlesData = allCompanyCadles
                return
            }
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

                switch self.activeInterval {
                case .week:
                    self.weekCompanyCandles = candles
                case .month:
                    self.monthCompanyCandles = candles
                case .sixMonths:
                    self.sixMonthCompanyCandles = candles
                case .year:
                    self.yearCompanyCandles = candles
                case .all:
                    self.allCompanyCadles = candles
                default:
                    break
                }
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
        let data = Data(text.utf8)
        var jsonData = Trades()
        do {
            jsonData = try JSONDecoder().decode(Trades.self, from: data)
            if let lastPrice = jsonData.data.last?.p {
                print(lastPrice)
                companyCandlesData!.c![companyCandlesData!.c!.endIndex - 1] = lastPrice //! mojet bit nil in companyCandlesData
                stockInfo.c = lastPrice
            }
        } catch {}
    }

    func onMessage(connection: WebSocketConnection, data: Data) {
        return
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

    deinit {
        print("Model deinit")
    }
}
