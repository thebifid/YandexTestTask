//
//  TableViewStockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import UIKit

class TableViewStockCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Private Properties

    let viewModel = StocksViewModel()

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
        addSubview(tableView)
        constrain(tableView) { tableView in
            tableView.left == tableView.superview!.left + 20
            tableView.right == tableView.superview!.right - 20
            tableView.top == tableView.superview!.top
            tableView.bottom == tableView.superview!.bottom
        }
        tableView.register(StockCell.self, forCellReuseIdentifier: "cellId")

        viewModel.requestTrendingList()
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trendingListInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! StockCell
        if indexPath.row % 2 == 0 {
//            cell.setupCell(color: R.color.customLightGray()!, companyName: viewModel.constituents[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
