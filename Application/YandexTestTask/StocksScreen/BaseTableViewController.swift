//
//  BaseTableViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 26.02.2021.
//

import Cartography
import UIKit

class BaseTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StockCellDelegate {
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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

    @objc private func refreshHandler(sender: UIRefreshControl) {}

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

    // MARK: StockCellDelegate

    func favButtonTapped(cell: StockCell) {}

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
