//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource, MenuBarDelegate, UISearchBarDelegate, SearchViewDelegate {
    func searchView(_ searchView: SearchView, didClickTag tag: String) {
        searchController.searchBar.searchTextField.text = tag
        searchBarSearchButtonClicked(searchController.searchBar)
        searchController.searchBar.resignFirstResponder()
    }

    func menuBar(didScrolledToIndex to: Int) {
        controllers.forEach { $0.deactivateFollowingNavbar() }
        controllers[to].activateFollowingNavbar()
    }

    // MARK: - Private Properties

    private let viewModel = StocksListViewModel()
    private let tabs = ["Stocks", "Favourite"]
    private lazy var controllers = [StocksListViewController(viewModel: viewModel), FavouriteListViewController(viewModel: viewModel)]

    // MARK: - UI Controls

    private let searchResController = SearchResViewController()

    private lazy var searchController = UISearchController(searchResultsController: searchResController)
    private var searchView: SearchView?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        barItemFontSize = 24
        setupSearchBar()
        enabliBinding()
    }

    private func enabliBinding() {
        viewModel.didUpdatePopularList = { [weak self] in
            guard self?.searchView != nil else { return }
            DispatchQueue.main.async {
                self?.searchView!.setPopularTags(tags: self?.viewModel.popularList ?? [])
            }
        }

        viewModel.didSearch = { [weak self] in
            self?.searchResController.setSearchResults(results: self?.viewModel.searchResult ?? [])
        }
    }

    // MARK: - Private Methods

    // MARK: - UI Actions

    private func setupSearchBar() {
        // Разобраться когда дойду
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = false

        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true

        searchController.searchBar.delegate = self
    }

    // MARK: - SearchBarDelegate

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.showsSearchResultsController = false
        guard searchView == nil else { return true }
        searchView = SearchView()
        searchView!.delegate = self
        searchView!.setPopularTags(tags: viewModel.popularList ?? [])
        view.addSubview(searchView!)
        constrain(searchView!) { searchView in
            searchView.edges == searchView.superview!.edges
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.showsSearchResultsController = true
        if let searchText = searchBar.text?.uppercased() {
            searchResController.startedSearch()
            viewModel.searchRequest(withText: searchText) { result in

                switch result {
                case let .failure(error):
                    break
                case .success:
                    self.searchResController.setSearchResults(results: self.viewModel.searchResult ?? [])
                }
            }
        }
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
