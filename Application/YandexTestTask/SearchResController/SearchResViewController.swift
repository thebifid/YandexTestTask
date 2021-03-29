//
//  SearchResViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 06.03.2021.
//

import Cartography
import MaterialComponents.MDCActivityIndicator
import UIKit

protocol SearchResControllerDelegate: AnyObject {
    func favButtonClicked(atIndexPath indexPath: IndexPath)
    func clickedCell(atIndexPath indexPath: IndexPath)
    func refreshButtonClicked()
}

class SearchResViewController: BaseControllerWithTableView, UITableViewDataSource, UITableViewDelegate, StockCellDelegate {
    // MARK: - Public Properties

    weak var delegate: SearchResControllerDelegate?

    // MARK: - UI Controls

    private let activityIndicator: MDCActivityIndicator = {
        let ai = MDCActivityIndicator()
        return ai
    }()

    private let noResultsFoundLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = R.font.montserratMedium(size: 18)
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
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
        setupRefreshButtonAction()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }

        view.addSubview(noResultsFoundLabel)
        constrain(noResultsFoundLabel) { noResultsFoundLabel in
            noResultsFoundLabel.center == noResultsFoundLabel.superview!.center
            noResultsFoundLabel.width == Constants.deviceWidth / 1.5
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func vibrate() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    @objc private func refreshButtonDidClicked() {
        delegate?.refreshButtonClicked()
    }

    // MARK: - Public Methods

    func setSearchResults(results: [TrendingListFullInfoModel], forSearchRequest term: String) {
        searchResult = results
        activityIndicator.stopAnimating()

        if results.isEmpty {
            noResultsFoundLabel.isHidden = false
            noResultsFoundLabel.text = "No results found for '\(term)'"
        }
    }

    func startedSearch() {
        noResultsFoundLabel.isHidden = true
        refreshButton.isHidden = true
        activityIndicator.startAnimating()
        searchResult = []
        tableView.reloadData()
    }

    func searchFailed() {
        activityIndicator.stopAnimating()
        refreshButton.isHidden = false
    }

    private func setupRefreshButtonAction() {
        refreshButton.addTarget(self, action: #selector(refreshButtonDidClicked), for: .touchUpInside)
    }

    // MARK: - StockCellDelegate

    func favButtonTapped(cell: StockCell) {
        vibrate()
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
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.clickedCell(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
