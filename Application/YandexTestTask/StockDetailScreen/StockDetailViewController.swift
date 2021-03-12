//
//  StockDetailViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import AMScrollingNavbar
import UIKit

class StockDetailViewController: MenuBarViewController {
    // MARK: - Private Properties

    private let viewModel: StockDetailViewModel!
    private lazy var controllers = [stockChartViewController, UIViewController()]
    private let titles = ["Chart", "Test"]

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setTitle(title: viewModel.ticker, subtitle: viewModel.companyName)

        stockChartViewController.addOverallLayer = { [weak self] view, options in
            self?.addOverallLayer(withView: view, options: options)
        }
    }

    // MARK: - Private Methods

    // MARK: - IntervalDelegate

    // MARK: - MenuBarDataSource

    private lazy var stockChartViewController: StockChartViewController = {
        let controller = StockChartViewController(barHeight: barCollectionView.frame.height,
                                                  viewModel: StockChartViewModel(stockModel: viewModel.stockInfo))
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
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinit
}
