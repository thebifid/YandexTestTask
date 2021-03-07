//
//  SearchResViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 06.03.2021.
//

import Cartography
import UIKit

protocol SearchResControllerDelegate: AnyObject {
    func favButtonClicked(atIndexPath indexPath: IndexPath)
}

class SearchResViewController: BaseControllerWithTableView, UITableViewDataSource, UITableViewDelegate, StockCellDelegate {
    weak var delegate: SearchResControllerDelegate?

    // MARK: - UI Controls

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .black
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Private Properties

    private var searchResult = [TrendingListFullInfoModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Public Methods

    func setSearchResults(results: [TrendingListFullInfoModel]) {
        searchResult = results
        activityIndicator.stopAnimating()
    }

    func startedSearch() {
        activityIndicator.startAnimating()
    }

    // MARK: - StockCellDelegate

    func favButtonTapped(cell: StockCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            delegate?.favButtonClicked(atIndexPath: indexPath)
        }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! StockCell
        let color: UIColor = indexPath.row % 2 == 0 ? R.color.customLightGray()! : .white
        cell.setupCell(color: color, companyInfo: searchResult[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
