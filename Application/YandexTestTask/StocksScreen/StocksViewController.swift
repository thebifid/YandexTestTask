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
        guard from >= 0, from <= controllers.count, to <= controllers.count else { return }

        if let navigationController = controllers[from].navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
        if let navigationController = controllers[to].navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(controllers[to].tableView, delay: 0, followers:
                [
                    NavigationBarFollower(view: barCollectionView),
                    NavigationBarFollower(view: contentCollectionView)
                ])
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationController = controllers[0].navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(controllers[0].tableView, delay: 0, followers:
                [
                    NavigationBarFollower(view: barCollectionView),
                    NavigationBarFollower(view: contentCollectionView)
                ])
        }
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
