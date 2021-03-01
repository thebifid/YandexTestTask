//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource, MenuBarDelegate {
    func menuBar(didScrolledFromIndex from: Int, to: Int) {
        if let controller = controllers[from] as? StocksListViewController {
            if let navigationController = controller.navigationController as? ScrollingNavigationController {
                navigationController.stopFollowingScrollView()
            }
        }

        if let controller = controllers[from] as? FavouriteListViewController {
            if let navigationController = controller.navigationController as? ScrollingNavigationController {
                navigationController.stopFollowingScrollView()
            }
        }

        if let controller = controllers[to] as? StocksListViewController {
            if let navigationController = controller.navigationController as? ScrollingNavigationController {
                navigationController.followScrollView(controller.tableView, delay: 50.0)
            }
        }

        if let controller = controllers[to] as? FavouriteListViewController {
            if let navigationController = controller.navigationController as? ScrollingNavigationController {
                navigationController.followScrollView(controller.tableView, delay: 50.0)
            }
        }
    }

    // MARK: - Private Properties

    private let viewModel = StocksListViewModel()
    private let tabs = ["Stocks", "Favourite"]
    private lazy var controllers = [StocksListViewController(viewModel: viewModel), FavouriteListViewController(viewModel: viewModel)]

    // MARK: - UI Controls

    private let searchController = UISearchController()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        barItemFontSize = 24
        setupSearchBar()
    }

    // MARK: - UI Actions

    private func setupSearchBar() {
        // Разобраться когда дойду
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal

        searchController.searchBar.placeholder = "Find company or ticker"

        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }

    // MARK: - MenuBarDataSource

    func menuBar(_ menuBar: MenuBarViewController, titleForPageAt index: Int) -> String {
        tabs[index]
    }

    func menuBar(_ menuBar: MenuBarViewController, viewControllerForPageAt index: Int) -> UIViewController {
        return controllers[index]
    }

    func numberOfPages(in swipeMenu: MenuBarViewController) -> Int {
        tabs.count
    }
}
