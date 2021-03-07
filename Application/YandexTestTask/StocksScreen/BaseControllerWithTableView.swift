//
//  BaseControllerWithTableView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 01.03.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

class BaseControllerWithTableView: UIViewController {
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
    }

    weak var cellDidScrollDelegate: CellDidScrollDelegate?
    weak var barCV: UICollectionView?

    // MARK: - UI Controls

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.contentInset = .init(top: barCV?.frame.height ?? 0, left: 0, bottom: 50, right: 0)
        return tableView
    }()

    // MARK: - Public Methods

    func deactivateFollowingNavbar() {
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }

    func activateFollowingNavbar() {
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 20, followers: [NavigationBarFollower(view: barCV!)])
        }
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
    }
}
