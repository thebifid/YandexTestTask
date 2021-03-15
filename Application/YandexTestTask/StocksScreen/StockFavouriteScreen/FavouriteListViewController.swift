//
//  FavouriteListViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 26.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

protocol CellDidScrollDelegate: AnyObject {
    func cellDidScroll(scrollView: UIScrollView)
}

class FavouriteListViewController: BaseControllerWithTableView, UITableViewDataSource, UITableViewDelegate, StockCellDelegate {
    // MARK: - Private Properties

    private let viewModel = FavouriteListViewModel()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        enableBinding()
        fetchFavs()
        setupPlaceholder()
    }

    // MARK: - UI Controls

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .black
        ai.hidesWhenStopped = true
        return ai
    }()

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshHandler(sender:)), for: .valueChanged)
        return refreshControl
    }()

    private let emptyFavsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "No fav stocks for now"
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 30)
        label.alpha = 0
        return label
    }()

    // MARK: - Selectors

    @objc private func refreshHandler(sender: UIRefreshControl) {
        fetchFavs()
    }

    // MARK: - UI Actions

    private func setupPlaceholder() {
        view.addSubview(emptyFavsPlaceholderLabel)
        constrain(emptyFavsPlaceholderLabel) { label in
            label.center == label.superview!.center
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(StockCell.self, forCellReuseIdentifier: "cellId")
        tableView.refreshControl = refreshControl
        tableView.addSubview(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateFavsList = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            if self.viewModel.favListInfo.isEmpty {
                self.emptyFavsPlaceholderLabel.alpha = 1
            } else {
                self.emptyFavsPlaceholderLabel.alpha = 0
            }
        }
    }

    private func vibrate() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    private func fetchFavs() {
        if viewModel.favListInfo.isEmpty {
            activityIndicator.startAnimating()
        }

        viewModel.fetchData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                let alert = AlertAssist.AlertWithTryAgainAction(withError: error) { _ in
                    self.fetchFavs()
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.present(alert, animated: true, completion: nil)
                }
            case .success:
                self.activityIndicator.stopAnimating()
            }

            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favListInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! StockCell
        let color: UIColor = indexPath.row % 2 == 0 ? R.color.customLightGray()! : .white
        cell.setupCell(color: color, companyInfo: viewModel.favListInfo[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewModel = StockDetailViewModel(stock: viewModel.favListInfo[indexPath.row])
        let controller = StockDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(controller, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cellDidScrollDelegate?.cellDidScroll(scrollView: scrollView)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let navigationController = navigationController as? ScrollingNavigationController {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                navigationController.showNavbar(animated: true, scrollToTop: true)
            }
        }
        return true
    }

    // MARK: - StockCellDelegate

    func favButtonTapped(cell: StockCell) {
        let indexPath = tableView.indexPath(for: cell)
        let index = indexPath!.row
        viewModel.stocksFavButtonTapped(index: index) { result in
            switch result {
            case let .failure(error):
                let alert = AlertAssist.AlertWithCancel(withError: error)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            case .success:
                self.vibrate()
            }
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
