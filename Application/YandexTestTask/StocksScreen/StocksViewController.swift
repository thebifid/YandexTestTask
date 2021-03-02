//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource, cellDidScrollDelegate {
    func cellDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 20 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            UIView.animate(withDuration: 0.1) {
                self.barCollectionView.transform = CGAffineTransform(translationX: 0, y: -45)
                self.contentCollectionView.transform = CGAffineTransform(translationX: 0, y: -45)
            }
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            UIView.animate(withDuration: 0.1) {
                self.barCollectionView.transform = CGAffineTransform.identity
                self.contentCollectionView.transform = CGAffineTransform.identity
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
