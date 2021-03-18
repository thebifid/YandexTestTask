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
    private lazy var controllers = [stockChartViewController, metricsViewController, newsViewController]
    private let titles = ["Chart", "Metrics", "News"]

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        stockChartViewController.addOverallLayer = { [weak self] view, options in
            self?.addOverallLayer(withView: view, options: options)
        }
    }

    // MARK: - Private Methods

    private func setupNavBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.setTitle(title: viewModel.ticker, subtitle: viewModel.companyName)
        if viewModel.inFav {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"),
                                                                style: .plain, target: self, action: #selector(favButtonTapped))
            navigationItem.rightBarButtonItem?.tintColor = R.color.customYellow()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"),
                                                                style: .plain, target: self, action: #selector(favButtonTapped))
            navigationItem.rightBarButtonItem?.tintColor = .black
        }
    }

    @objc private func favButtonTapped() {
        viewModel.stocksFavButtonTapped { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case .success:
                self?.setupNavBar()
            }
        }
    }

    // MARK: - IntervalDelegate

    // MARK: - MenuBarDataSource

    private lazy var stockChartViewController: StockChartViewController = {
        let controller = StockChartViewController(barHeight: barCollectionView.frame.height,
                                                  viewModel: StockChartViewModel(stockModel: viewModel.stockInfo))
        return controller
    }()

    private lazy var metricsViewController: MetricsViewController = {
        let controller = MetricsViewController(viewModel: MetricsViewModel(stockInfo: viewModel.stockInfo))
        return controller
    }()

    private lazy var newsViewController: NewsViewController = {
        let controller = NewsViewController(viewModel: NewsViewModel(symbol: viewModel.stockInfo.ticker))
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
