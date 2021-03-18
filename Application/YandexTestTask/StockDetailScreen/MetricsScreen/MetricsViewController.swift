//
//  MetricsViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import UIKit

class MetricsViewController: UITableViewController {
    private let sectionTitles = ["Financial indicators", "Cost estimation", "Profitability", "Dividends", "Trade"]

    private let viewModel: MetricsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        enableBinding()
        requestData()
        view.backgroundColor = .white
    }

    private func enableBinding() {
        viewModel.didUpdateModel = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    private func requestData() {
        viewModel.requestCompanyMetrics { [weak self] result in
            switch result {
            case let .failure(error):
                let alert = AlertAssist.AlertWithTryAgainAction(withError: error) { _ in
                    self?.requestData()
                }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }

            case .success:
                break
            }
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView(withTitle: sectionTitles[section])
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

    init(viewModel: MetricsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
