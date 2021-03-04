//
//  BaseControllerWithTableView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 01.03.2021.
//

import Cartography
import UIKit

class BaseControllerWithTableView: UIViewController {
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    weak var cellDidScrollDelegate: CellDidScrollDelegate?

    // MARK: - UI Controls

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
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
}
