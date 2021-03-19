//
//  NewsCell.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 15.03.2021.
//

import Cartography
import UIKit

class NewsCell: UITableViewCell {
    // MARK: - UI Contorls

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratBold(size: 18)
        label.numberOfLines = 0
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = R.font.montserratMedium(size: 16)
        label.textColor = .gray
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = R.font.montserratMedium(size: 14)
        return label
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = R.font.montserratMedium(size: 14)
        return label
    }()

    // MARK: - Private Methods

    private func setupUI() {
        addSubview(headlineLabel)
        constrain(headlineLabel) { headlineLabel in
            headlineLabel.left == headlineLabel.superview!.left + 20
            headlineLabel.right == headlineLabel.superview!.right - 20
            headlineLabel.top == headlineLabel.superview!.top + 10
        }

        addSubview(summaryLabel)
        constrain(summaryLabel, headlineLabel) { summaryLabel, headlineLabel in
            summaryLabel.top == headlineLabel.bottom + 10
            summaryLabel.left == headlineLabel.left
            summaryLabel.right == headlineLabel.right
        }

        addSubview(dateLabel)
        constrain(dateLabel, summaryLabel) { dateLabel, summaryLabel in
            dateLabel.top == summaryLabel.bottom + 10
            dateLabel.left == summaryLabel.left
            dateLabel.bottom == dateLabel.superview!.bottom - 10
        }

        addSubview(sourceLabel)
        constrain(sourceLabel, dateLabel) { sourceLabel, dateLabel in
            sourceLabel.left == dateLabel.right + 5
            sourceLabel.top == dateLabel.top
        }
    }

    // MARK: - Public Methods

    func configure(withNewsModel model: NewsModel) {
        headlineLabel.text = model.headline
        summaryLabel.text = model.summary
        let date = Date(timeIntervalSince1970: model.datetime)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy hh:mm"
        dateLabel.text = formatter.string(from: date)
        sourceLabel.text = "- \(model.source)"
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
