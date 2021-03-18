//
//  StockChartViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Foundation

class StockChartViewModel: WebSocketConnectionDelegate {
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
            if let previousClose = companyCandlesData?.c?.first {
                return previousClose
            } else {
                return 0
            }
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

    var currency: String {
        return stockInfo.currency
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

    private(set) var activeInterval: IntevalTime = IntevalTime(rawValue: UserDefaults.standard.value(forKey: "activeInterval")
        as? Int ?? 0)! {
        didSet {
            requestCompanyCandles { _ in }
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

    func dateForCandle(forIndex index: Int) -> String {
        let timeStamp = companyCandlesData?.t?[index]
        guard timeStamp != nil else { return "" }
        let date = Date(timeIntervalSince1970: Double(timeStamp!))
        let dateFormatter = DateFormatter()

        if activeInterval.rawValue < 3 {
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
        }

        let strDate = dateFormatter.string(from: date)

        return strDate
    }

    private var requestCandlesTimer: Timer?

    private func setRequestCandlesTimer() {
        if activeInterval == .day {
            requestCandlesTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self,
                                                       selector: #selector(requestCandles), userInfo: nil, repeats: true)
        } else {
            requestCandlesTimer?.invalidate()
        }
    }

    func setActiveInterval(withNewInterval interval: IntevalTime) {
        UserDefaults.standard.set(interval.rawValue, forKey: "activeInterval")
        activeInterval = interval
        setRequestCandlesTimer()
    }

    @objc private func requestCandles() {
        requestCompanyCandles { _ in }
    }

    func requestCompanyCandles(completion: @escaping (Result<Void, Error>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else { return }

        var fromIntervalTime: String!
        var resolution: String!

        let activeInterval = self.activeInterval

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
                completion(.failure(error))
            case let .success(candles):
                self.companyCandlesData = candles

                switch activeInterval {
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
                if companyCandlesData != nil {
                    companyCandlesData!.c![companyCandlesData!.c!.endIndex - 1] = lastPrice
                    stockInfo.c = lastPrice
                }
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
        setRequestCandlesTimer()
    }
}
