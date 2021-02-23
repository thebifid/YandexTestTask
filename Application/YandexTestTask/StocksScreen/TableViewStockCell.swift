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
        return tableView
    }()

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
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateModel = {
            self.tableView.reloadData()
        }
    }

    private func requestData() {
        viewModel.requestTrendingList { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)

            case .success:
                break
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
