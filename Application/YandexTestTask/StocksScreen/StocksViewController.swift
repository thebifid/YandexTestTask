//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource, MenuBarDelegate, CellDidScrollDelegate, UISearchBarDelegate {
    func menuBar(didScrolledToIndex to: Int) {
        controllers.forEach { $0.deactivateFollowingNavbar() }
        controllers[to].activateFollowingNavbar()
    }

    func cellDidScroll(scrollView: UIScrollView) {}

    // MARK: - Private Properties

    private let viewModel = StocksListViewModel()
    private let tabs = ["Stocks", "Favourite"]
    private lazy var controllers = [StocksListViewController(viewModel: viewModel), FavouriteListViewController(viewModel: viewModel)]

    // MARK: - UI Controls

    private let searchController = UISearchController()
    private var searchView: SearchView?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        barItemFontSize = 24
        setupSearchBar()
    }

    // MARK: - Private Methods


    // MARK: - UI Actions

    private func setupSearchBar() {
        // Разобраться когда дойду
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.obscuresBackgroundDuringPresentation = false
        
        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true

        searchController.searchBar.delegate = self
    }

    // MARK: - SearchBarDelegate

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard searchView == nil else { return true }
        searchView = SearchView()
        view.addSubview(searchView!)
        constrain(searchView!) { (searchView) in
            searchView.edges == searchView.superview!.edges
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchView?.removeFromSuperview()
        searchView = nil
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
