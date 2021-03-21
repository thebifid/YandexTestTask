//
//  StockChartViewModel.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import EasyStash
import Foundation

class StockChartViewModel: WebSocketConnectionDelegate {
    // MARK: - Private Properties

    private var stockInfo: TrendingListFullInfoModel!

    private var companyCandlesData: CandlesModel?

    private var requestCandlesTimer: Timer?

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

    /// Return stringDate from timestamp
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

    /// Change interval (D, W, M, 6M, 1Y, ALL) when user click button
    func setActiveInterval(withNewInterval interval: IntevalTime) {
        UserDefaults.standard.set(interval.rawValue, forKey: "activeInterval")
        activeInterval = interval
        setRequestCandlesTimer()
    }

    @objc private func requestCandles() {
        requestCompanyCandles { _ in }
    }

    private let resolutions = ["5", "60", "240", "D", "D", "M"]
    private lazy var intervalFrom = [
        dayStartTimestamp,
        weekBackTimestamp,
        monthBackTimestamp,
        sixMonthBackTimestamp,
        yearBackTimestamp,
        "0"
    ]

    func requestCompanyCandles(completion: @escaping (Result<Void, Error>) -> Void) {
        guard NetworkMonitor.sharedInstance.isConnected else { return }
        let activeInterval = self.activeInterval
        let resolution = resolutions[activeInterval.rawValue]
        let intervalFrom = self.intervalFrom[activeInterval.rawValue]

        var storage: Storage?
        var options: Options = Options()
        options.folder = "Cache"
        storage = try? Storage(options: options)

        if let candles = try? storage?.load(forKey: "\(activeInterval)Candles\(ticker)",
                                            as: CandlesModel.self, withExpiry: .maxAge(maxAge: 300)) {
            companyCandlesData = candles
            didUpdateCandles?()
            return
        }

        NetworkService.sharedInstance.requestCompanyCandle(withSymbol: ticker,
                                                           resolution: resolution, from: intervalFrom, to: currentTimestamp) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(candles):
                self.companyCandlesData = candles
                try? storage?.save(object: candles, forKey: "\(activeInterval)Candles\(self.ticker)")
                if activeInterval == self.activeInterval {
                    self.didUpdateCandles?()
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Получение информации для графика каждые 5 минут
    /// Когда приходит новая цена через веб сокет, то обновляется только последнее значение в графике, без удлинения
    /// графика по оси х (потому что интервал графика = 5 минут)
    private func setRequestCandlesTimer() {
        if activeInterval == .day {
            requestCandlesTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self,
                                                       selector: #selector(requestCandles), userInfo: nil, repeats: true)
        } else {
            requestCandlesTimer?.invalidate()
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
