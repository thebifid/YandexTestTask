//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: MenuBarViewController, MenuBarDataSource, MenuBarDelegate, CellDidScrollDelegate {
    func menuBar(didScrolledToIndex to: Int) {
        controllers.forEach { controller in
            controller.tableView.isScrollEnabled = false
        }
        controllers[to].tableView.isScrollEnabled = true
    }

    func cellDidScroll(scrollView: UIScrollView) {
        let navBarHeight = navigationController!.navigationBar.frame.height

        guard let navController = navigationController else { return }

        if scrollView.contentOffset.y > 200 {
            if !navController.isNavigationBarHidden {
                UIView.animate(withDuration: 0.1) {
                    self.navigationController?.navigationBar.alpha = 0
                    self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: -navBarHeight)
                    self.barCollectionView.transform = CGAffineTransform(translationX: 0, y: -navBarHeight)

                    self.contentCollectionView.transform = CGAffineTransform(translationX: 0, y: -navBarHeight)
                } completion: { _ in
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
            }

        } else if scrollView.contentOffset.y < 200, scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            if navController.isNavigationBarHidden {
                navigationController?.setNavigationBarHidden(false, animated: false)
                UIView.animate(withDuration: 0.1) {
                    self.navigationController?.navigationBar.alpha = 1
                    self.navigationController?.navigationBar.transform = CGAffineTransform.identity
                    self.barCollectionView.transform = CGAffineTransform.identity
                    self.contentCollectionView.transform = CGAffineTransform.identity
                }
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
