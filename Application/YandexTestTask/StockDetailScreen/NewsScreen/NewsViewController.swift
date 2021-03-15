//
//  NewsViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 15.03.2021.
//

import Cartography
import SafariServices
import UIKit

class NewsViewController: UITableViewController {
    // MARK: - Private Properties

    private let viewModel: NewsViewModel!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        enableBinding()
        viewModel.requestCompanyNews()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(NewsCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: .zero)
    }

    // MARK: - Private Methods

    private func enableBinding() {
        viewModel.didUpdateModel = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    private func goToSource(index: Int) {
        if let url = URL(string: viewModel.news[index].url) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! NewsCell
        cell.configure(withNewsModel: viewModel.news[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        goToSource(index: indexPath.row)
    }

    // MARK: - Init

    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
