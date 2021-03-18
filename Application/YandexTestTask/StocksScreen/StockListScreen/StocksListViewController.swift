//
//  StocksListViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

class StocksListViewController: BaseControllerWithTableView, UITableViewDataSource, UITableViewDelegate, StockCellDelegate {
    // MARK: - Private Properties

    private let viewModel = StocksListViewModel()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        enableBinding()
        requestData()
        activateFollowingNavbar()
        setupNoICView()
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

    private lazy var noICview = NoInternetConnectionView {
        self.requestData()
    }

    // MARK: - Selectors

    @objc private func refreshHandler(sender: UIRefreshControl) {
        requestData()
    }

    // MARK: - UI Actions

    private func setupNoICView() {
        view.addSubview(noICview)
        noICview.isHidden = true
        constrain(noICview) { noICview in
            noICview.center == noICview.superview!.center
            noICview.width == Constants.deviceWidth / 1.5
            noICview.height == 80
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.addSubview(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateStocksList = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func vibrate() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    private func requestData() {
        if viewModel.trendingListInfo.isEmpty {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.noICview.isHidden = true
            }
        }
        viewModel.requestTrendingList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(.notConnected):
                DispatchQueue.main.async {
                    self.noICview.isHidden = false
                    self.activityIndicator.stopAnimating()
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    let alert = AlertAssist.AlertWithTryAgainAction(withError: error, action: { _ in
                        self.requestData()
                    })
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.present(alert, animated: true, completion: nil)
                    self.noICview.isHidden = true
                }
            case .success:
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                    self.noICview.isHidden = true
                }
            }
        }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trendingListInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! StockCell
        let color: UIColor = indexPath.row % 2 == 0 ? R.color.customLightGray()! : .white
        cell.setupCell(color: color, companyInfo: viewModel.trendingListInfo[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewModel = StockDetailViewModel(stock: viewModel.trendingListInfo[indexPath.row])
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

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
