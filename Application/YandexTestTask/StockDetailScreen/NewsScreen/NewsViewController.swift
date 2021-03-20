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

    // MARK: - UI Controls

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .black
        ai.hidesWhenStopped = true
        return ai
    }()

    private lazy var noICview = NoInternetConnectionView {
        self.requestCompanyNews()
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCompanyNews()
        enableBinding()
        setupTableView()
        setupNoICView()
    }

    // MARK: - UI Actions

    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(NewsCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.addSubview(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.centerX == activityIndicator.superview!.centerX
            activityIndicator.centerY == activityIndicator.superview!.centerY / 2
        }
    }

    // MARK: - Private Methods

    private func setupNoICView() {
        view.addSubview(noICview)
        noICview.isHidden = true
        constrain(noICview) { noICview in
            noICview.center == noICview.superview!.center
            noICview.width == Constants.deviceWidth / 1.5
            noICview.height == 80
        }
    }

    private func requestCompanyNews() {
        activityIndicator.startAnimating()
        noICview.isHidden = true
        viewModel.requestCompanyNews { [weak self] result in
            switch result {
            case let .failure(.connected(error)):
                let alert = AlertAssist.AlertWithTryAgainAction(withError: error) { _ in
                    self?.requestCompanyNews()
                }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                    self?.noICview.isHidden = true
                }
            case .success:
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.noICview.isHidden = true
                }

            case .failure(.notConnected):
                DispatchQueue.main.async {
                    self?.noICview.isHidden = false
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }

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
