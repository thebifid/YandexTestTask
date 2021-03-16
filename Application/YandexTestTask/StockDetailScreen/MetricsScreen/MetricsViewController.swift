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
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "KEKW"
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView(withTitle: sectionTitles[section])
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
}
