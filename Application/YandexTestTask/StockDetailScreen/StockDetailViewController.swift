//
//  StockDetailViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import AMScrollingNavbar
import UIKit

class StockDetailViewController: MenuBarViewController, IntervalDelegate {
    func intervalDidChange(newInterval interval: StockDetailViewModel.IntevalTime) {
        viewModel.setActiveInterval(withNewInterval: interval)
    }

    // MARK: - Private Properties

    private var viewModel: StockDetailViewModel!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        stockChartViewController.addOverallLayer = { view, options in
            self.addOverallLayer(withView: view, options: options)
        }

        navigationItem.setTitle(title: viewModel.ticker, subtitle: viewModel.companyName)
//        connectWebSocket()
        viewModel.requestCompanyCandles()

        viewModel.didUpdateCandles = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.stockChartViewController.setData(withPrices: self.viewModel.candles)
            }
        }
    }

//    private func connectWebSocket() {
//        webSocketConnection = WebSocketTaskConnection(url: URL(string: "wss://ws.finnhub.io?token=c0mgb5748v6ue78flnkg")!)
//        webSocketConnection.delegate = self
//        webSocketConnection.connect()
//        webSocketConnection.send(text: "{\"type\":\"subscribe\",\"symbol\":\"AAPL\"}")
//    }

    // MARK: - MenuBarDataSource

    private lazy var stockChartViewController: StockChartViewController = {
        let controller = StockChartViewController(barHeight: barCollectionView.frame.height,
                                                  activeInterval: viewModel.activeInterval.rawValue)
        controller.delegate = self
        return controller
    }()

    private lazy var controllers = [stockChartViewController, UIViewController()]
    private let titles = ["Chart", "Test"]

    override func menuBar(_ menuBar: MenuBarViewController, titleForPageAt index: Int) -> String {
        titles[index]
    }

    override func menuBar(_ menuBar: MenuBarViewController, viewControllerForPageAt index: Int) -> UIViewController {
        controllers[index]
    }

    override func numberOfPages(in swipeMenu: MenuBarViewController) -> Int {
        controllers.count
    }

    // MARK: - Init

    init(viewModel: StockDetailViewModel) {
        super.init()
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
