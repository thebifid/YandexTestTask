//
//  MetricsViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 16.03.2021.
//

import UIKit

class MetricsViewController: UITableViewController {
    private let sectionTitles = ["Financial indicators", "Cost estimation", "Profitability", "Dividends", "Trade"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(MetricsCell.self, forCellReuseIdentifier: "cellId")

        tableView.sectionFooterHeight = 0
        tableView.separatorColor = .clear

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView(withTitle: sectionTitles[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MetricsCell
        cell.configure(withTitle: "1", subtitle: "2", value: "18%")
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
}
