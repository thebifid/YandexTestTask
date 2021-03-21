//
//  MetricsViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import Cartography
import MaterialComponents.MDCActivityIndicator
import UIKit

class MetricsViewController: UITableViewController {
    // MARK: - Private Properties

    private let viewModel: MetricsViewModel!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        enableBinding()
        requestData()
        setupUI()
        setupNoICView()
        setupRefreshButton()
        view.backgroundColor = .white
    }

    // MARK: - UI Controls

    private let activityIndicator: MDCActivityIndicator = {
        let ai = MDCActivityIndicator()
        return ai
    }()

    private lazy var noICview = NoInternetConnectionView {
        self.requestData()
    }

    private lazy var notification = NotificationView(to: self)

    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.refresh(), for: .normal)
        return button
    }()

    // MARK: - UI Actions

    private func setupNoICView() {
        view.addSubview(noICview)
        noICview.isHidden = true
        constrain(noICview) { noICview in
            noICview.center == noICview.superview!.center
            noICview.width == Constants.deviceWidth / 1.5
            noICview.height == 80
        }
    }

    private func setupUI() {
        view.addSubview(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(MetricsCell.self, forCellReuseIdentifier: "cellId")

        tableView.sectionFooterHeight = 0
        tableView.separatorColor = .clear

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
        tableView.allowsSelection = false
    }

    private func setupRefreshButton() {
        view.addSubview(refreshButton)
        refreshButton.isHidden = true
        refreshButton.addTarget(self, action: #selector(requestDataByRefreshButton), for: .touchUpInside)
        constrain(refreshButton) { refreshButton in
            refreshButton.center == refreshButton.superview!.center
            refreshButton.height == 40
            refreshButton.width == 40
        }
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateModel = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    private func requestData() {
        activityIndicator.startAnimating()
        noICview.isHidden = true
        refreshButton.isHidden = true
        viewModel.requestCompanyMetrics { [weak self] result in
            switch result {
            case .failure(.notConnected):
                DispatchQueue.main.async {
                    self?.noICview.isHidden = false
                    self?.activityIndicator.stopAnimating()
                }

            case .failure:
                DispatchQueue.main.async {
                    self?.notification.show(type: .failure)
                    self?.activityIndicator.stopAnimating()
                    self?.noICview.isHidden = true
                    self?.refreshButton.isHidden = false
                }

            case .success:
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.noICview.isHidden = true
                }
            }
        }
    }

    @objc private func requestDataByRefreshButton() {
        requestData()
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView(withTitle: viewModel.sectionTitles[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.metricsData[section].count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MetricsCell
        let metrics = viewModel.metricsData
        let section = indexPath.section
        let row = indexPath.row
        cell.configure(withTitle: viewModel.metricsTitles[section][row],
                       subtitle: viewModel.metricsSubtitles[section][row], value: metrics[section][row])
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.metricsData.count
    }

    // MARK: - Init

    init(viewModel: MetricsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
