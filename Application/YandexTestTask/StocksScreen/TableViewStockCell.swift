//
//  TableViewStockCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 20.02.2021.
//

import Cartography
import UIKit

class TableViewStockCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    // MARK: - UI Controls

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    // MARK: - UI Actions

    private func setupTableView() {
        addSubview(tableView)
        constrain(tableView) { tableView in
            tableView.edges == tableView.superview!.edges
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = "Test"
        return cell
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
