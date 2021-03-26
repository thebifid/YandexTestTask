//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

class StocksViewController: MenuBarViewController, UISearchBarDelegate, SearchViewDelegate, SearchResControllerDelegate {
    // MARK: - Private Properties

    private let viewModel = StocksViewModel()
    private let tabs = ["Stocks", "Favourite"]
    private lazy var controllers = [StocksListViewController(), FavouriteListViewController()]

    // MARK: - UI Controls

    private let searchResController = SearchResViewController()
    private lazy var searchController = UISearchController(searchResultsController: searchResController)
    private var searchView: SearchView?

    private lazy var notification = NotificationView(to: searchResController)

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        barItemFontSize = 24
        searchResController.delegate = self
        requestPopularRequests()
        enableBinding()
        setupSearchBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdatePopularList = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.searchView?.setPopularTags(tags: self.viewModel.popularList)
            }
        }

        viewModel.didFavButtonClicked = { [weak self] in
            self?.searchResController.tableView.reloadData()
        }
    }

    func refreshButtonClicked(_ searchView: SearchView) {
        requestPopularRequests()
    }

    private func requestPopularRequests() {
        viewModel.requestTrendingList { [weak self] result in
            switch result {
            case .failure(.notConnected):
                self?.searchView?.setICStatus(status: NetworkMonitor.sharedInstance.isConnected)

            case .failure:
                break
            case .success:
                break
            }
        }
    }

    // MARK: - UI Actions

    private func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.searchTextField.font = R.font.montserratMedium(size: 14)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }

    // MARK: - SearchResControllerDelegate

    func favButtonClicked(atIndexPath indexPath: IndexPath) {
        viewModel.stockFavButtonTapped(index: indexPath.item) { [weak self] result in
            switch result {
            case let .failure(error):
                let alert = AlertAssist.AlertWithCancel(withError: error)
                self?.present(alert, animated: true, completion: nil)
            case .success:
                break
            }
        }
    }

    func clickedCell(atIndexPath indexPath: IndexPath) {
        let detailViewModel = StockDetailViewModel(stock: viewModel.searchResult[indexPath.row])
        let controller = StockDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - SearchBarDelegate

    func searchView(_ searchView: SearchView, didClickTag tag: String) {
        searchController.searchBar.searchTextField.text = tag
        searchBarSearchButtonClicked(searchController.searchBar)
        searchController.searchBar.resignFirstResponder()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.tintColor = .systemBlue
        searchController.showsSearchResultsController = false
        guard searchView == nil else { return true }
        searchView = SearchView()
        searchView!.delegate = self
        searchView!.setPopularTags(tags: viewModel.popularList)
        searchView!.setSearchedTags(tags: viewModel.searchedList)
        searchView!.setICStatus(status: NetworkMonitor.sharedInstance.isConnected)
        view.addSubview(searchView!)
        constrain(searchView!) { searchView in
            searchView.edges == searchView.superview!.edges
        }
        return true
    }

    // delegate
    func refreshButtonClicked() {
        searchBarSearchButtonClicked(searchController.searchBar)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.showsSearchResultsController = true
        if let searchText = searchBar.text {
            if viewModel.saveSerchRequestTerm(withTerm: searchText) {
                searchView?.addTag(withTag: searchText)
            }
            searchResController.startedSearch()
            viewModel.searchRequest(withText: searchText.uppercased()) { result in
                switch result {
                case .failure:
                    DispatchQueue.main.async {
                        self.notification.show(type: .failure)
                        self.searchResController.searchFailed()
                    }

                case .success:
                    self.searchResController.setSearchResults(results: self.viewModel.searchResult, forSearchRequest: searchText)
                }
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.tintColor = .white
        searchView?.removeFromSuperview()
        searchView = nil
    }

    // MARK: - MenuBarDelegate

    override func menuBar(didScrolledToIndex to: Int) {
        controllers.forEach { $0.deactivateFollowingNavbar() }
        controllers[to].activateFollowingNavbar()
    }

    // MARK: - MenuBarDataSource

    override func menuBar(_ menuBar: MenuBarViewController, titleForPageAt index: Int) -> String {
        tabs[index]
    }

    override func menuBar(_ menuBar: MenuBarViewController, viewControllerForPageAt index: Int) -> UIViewController {
        return controllers[index]
    }

    override func numberOfPages(in swipeMenu: MenuBarViewController) -> Int {
        tabs.count
    }
}
