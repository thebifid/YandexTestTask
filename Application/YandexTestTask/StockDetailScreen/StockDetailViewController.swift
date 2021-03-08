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

    private var viewModel: StockDetailViewModel!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setTitle(title: viewModel.ticker, subtitle: viewModel.companyName)
    }

    // MARK: - MenuBarDataSource

    private let controllers = [StockChartViewController(), UIViewController()]
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
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
