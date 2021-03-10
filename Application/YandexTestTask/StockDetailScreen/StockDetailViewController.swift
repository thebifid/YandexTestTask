//
//  StockDetailViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import AMScrollingNavbar
import UIKit

class StockDetailViewController: MenuBarViewController, IntervalDelegate {
    // MARK: - Private Properties

    private var viewModel: StockDetailViewModel!
    private lazy var controllers = [stockChartViewController, UIViewController()]
    private let titles = ["Chart", "Test"]

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setTitle(title: viewModel.ticker, subtitle: viewModel.companyName)
        viewModel.requestCompanyCandles()
        enableBinding()
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateCandles = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.stockChartViewController.setData(withPrices: self.viewModel.candles,
                                                      openPrice: self.viewModel.previousClose)
                self.stockChartViewController.setNewPrice(withCurrentPrice: self.viewModel.currentPrice,
                                                          previousClose: self.viewModel.previousClose)
            }
        }

        stockChartViewController.addOverallLayer = { [weak self] view, options in
            self?.addOverallLayer(withView: view, options: options)
        }
    }

    // MARK: - IntervalDelegate

    func intervalDidChange(newInterval interval: StockDetailViewModel.IntevalTime) {
        viewModel.setActiveInterval(withNewInterval: interval)
    }

    // MARK: - MenuBarDataSource

    private lazy var stockChartViewController: StockChartViewController = {
        let controller = StockChartViewController(barHeight: barCollectionView.frame.height,
                                                  activeInterval: viewModel.activeInterval.rawValue,
                                                  currentPrice: viewModel.currentPrice, previousClose: viewModel.previousClose)
        controller.delegate = self
        return controller
    }()

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
        self.viewModel.connectWebSocket()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinit

    deinit {
        print("controller deinit")
        self.viewModel.disconnectWebSocket()
    }
}
