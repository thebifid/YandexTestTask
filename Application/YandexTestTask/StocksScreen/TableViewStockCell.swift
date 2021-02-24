//
//  TableViewStockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import UIKit

class TableViewStockCell: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Private Properties

    let viewModel = StocksViewModel()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        enableBinding()

        print("requesting")
        requestData()
    }

    // MARK: - UI Controls

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        return tableView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .green
        ai.hidesWhenStopped = true
        return ai
    }()

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshHandler(sender:)), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Selectors

    @objc private func refreshHandler(sender: UIRefreshControl) {
        requestData()
    }

    // MARK: - UI Actions

    private func setupTableView() {
        view.addSubview(tableView)
        constrain(tableView) { tableView in
            tableView.left == tableView.superview!.left + 20
            tableView.right == tableView.superview!.right - 20
            tableView.top == tableView.superview!.top
            tableView.bottom == tableView.superview!.bottom
        }
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
        viewModel.didUpdateModel = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func requestData() {
        if viewModel.trendingListInfo.isEmpty {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }
        viewModel.requestTrendingList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                DispatchQueue.main.async {
                    let alert = AlertAssist.AlertWithAction(withError: error)
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.present(alert, animated: true, completion: nil)
                }
            case .success:
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
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
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // MARK: - Init
}
