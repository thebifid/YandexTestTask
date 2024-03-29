//
//  NewsViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 15.03.2021.
//

import Cartography
import MaterialComponents.MDCActivityIndicator
import SafariServices
import UIKit

class NewsViewController: UITableViewController {
    // MARK: - Private Properties

    private let viewModel: NewsViewModel!

    // MARK: - UI Controls

    private let activityIndicator: MDCActivityIndicator = {
        let ai = MDCActivityIndicator()
        return ai
    }()

    private let noNewsLabel: UILabel = {
        let label = UILabel()
        label.text = "No news for this week"
        label.textColor = .lightGray
        label.font = R.font.montserratLight(size: 18)
        label.numberOfLines = 0
        return label
    }()

    private lazy var noICview = NoInternetConnectionView {
        self.requestCompanyNews()
    }

    private lazy var notification = NotificationView(to: self)

    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.refresh(), for: .normal)
        return button
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCompanyNews()
        enableBinding()
        setupTableView()
        setupNoICView()
        setupNoNewsLabel()
        setupRefreshButton()
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

    private func setupRefreshButton() {
        view.addSubview(refreshButton)
        refreshButton.isHidden = true
        refreshButton.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        constrain(refreshButton) { refreshButton in
            refreshButton.center == refreshButton.superview!.center
            refreshButton.height == 40
            refreshButton.width == 40
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

    private func setupNoNewsLabel() {
        view.addSubview(noNewsLabel)
        constrain(noNewsLabel) { noNewsLabel in
            noNewsLabel.center == noNewsLabel.superview!.center
        }
        noNewsLabel.isHidden = true
    }

    @objc private func refreshData() {
        requestCompanyNews()
    }

    private func requestCompanyNews() {
        activityIndicator.startAnimating()
        noICview.isHidden = true
        refreshButton.isHidden = true
        viewModel.requestCompanyNews { [weak self] result in
            switch result {
            case .failure(.connected):
                DispatchQueue.main.async {
                    self?.notification.show(type: .failure)
                    self?.noICview.isHidden = true
                    self?.refreshButton.isHidden = false
                    self?.activityIndicator.stopAnimating()
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
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.viewModel.news.isEmpty {
                    self.noNewsLabel.isHidden = false
                }
                self.tableView.reloadData()
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
