//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource {
    // MARK: - Private Properties

    private let tabs = ["Stocks", "Favourite"]

    // MARK: - UI Controls

    private let searchController = UISearchController()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        barItemFontSize = 24
        setupSearchBar()
    }

    // MARK: - UI Actions

    private func setupSearchBar() {
        // Разобраться когда дойду
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }

    // MARK: - MenuBarDataSource

    func menuBar(_ menuBar: MenuBarViewController, titleForPageAt index: Int) -> String {
        tabs[index]
    }

    func menuBar(_ menuBar: MenuBarViewController, viewControllerForPageAt index: Int) -> UIViewController {
        return TableViewStockCell()
    }

    func numberOfPages(in swipeMenu: MenuBarViewController) -> Int {
        tabs.count
    }
}
