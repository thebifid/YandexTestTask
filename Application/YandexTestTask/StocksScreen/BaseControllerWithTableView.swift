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
    // MARK: - Public Properties

    weak var cellDidScrollDelegate: CellDidScrollDelegate?
    weak var barCV: UICollectionView?

    // MARK: - UI Controls

    lazy var notification = NotificationView(to: self)

    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.refresh(), for: .normal)
        return button
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupRefreshButton()
    }

    // MARK: - UI Controls

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
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

    private func setupRefreshButton() {
        view.addSubview(refreshButton)
        refreshButton.isHidden = true
        constrain(refreshButton) { refreshButton in
            refreshButton.center == refreshButton.superview!.center
            refreshButton.height == 40
            refreshButton.width == 40
        }
    }
}
