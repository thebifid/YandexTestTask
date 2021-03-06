//
//  TagsView.swift
//  TestyingCartography
//
//  Created by Vasiliy Matveev on 05.03.2021.
//

import Cartography
import UIKit

protocol TagsViewDataSource: AnyObject {
    func titleForHeader(_ tagView: TagsView) -> String
    func titlesForButtons(_ tagView: TagsView) -> [String]
}

protocol TagsViewDelegate: AnyObject {
    func tagDidClicked(_ tagView: TagsView, tagText text: String)
}

class TagsView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    weak var dataSource: TagsViewDataSource? {
        didSet {
            setupUI()
        }
    }

    weak var delegate: TagsViewDelegate?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular requests"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()

    private func setupUI() {
        backgroundColor = .white
        addSubview(titleLabel)
        constrain(titleLabel) { titleLabel in
            titleLabel.left == titleLabel.superview!.left + 20
            titleLabel.top == titleLabel.superview!.top
            titleLabel.height == 30
        }

        titleLabel.text = dataSource?.titleForHeader(self)

        addSubview(scrollView)
        constrain(scrollView, titleLabel) { scrollView, titleLabel in
            scrollView.top == titleLabel.bottom
            scrollView.width == scrollView.superview!.width
            scrollView.bottom == scrollView.superview!.bottom
        }

        let arrayOfTitles = dataSource?.titlesForButtons(self)
        var topArrayTitles = [String]()
        var bottomArrayTitles = [String]()

        guard let unwrapArrayOfTitles = arrayOfTitles else { return }

        if unwrapArrayOfTitles.count < 5 {
            topArrayTitles = unwrapArrayOfTitles
        } else {
            for index in stride(from: 0, to: unwrapArrayOfTitles.count, by: 2) {
                topArrayTitles.append(unwrapArrayOfTitles[index])
                if index + 1 < unwrapArrayOfTitles.count {
                    bottomArrayTitles.append(unwrapArrayOfTitles[index + 1])
                }
            }
        }

        let topStackView = UIStackView(arrangedSubviews: makeButtons(withTitles: topArrayTitles))
        let bottomStackView = UIStackView(arrangedSubviews: makeButtons(withTitles: bottomArrayTitles))
        topStackView.distribution = .fillProportionally
        bottomStackView.distribution = .fillProportionally

        topStackView.spacing = 10
        bottomStackView.spacing = 5

        scrollView.addSubview(topStackView)
        constrain(topStackView) { topStackView in
            topStackView.top == topStackView.superview!.top + 10
            topStackView.left == topStackView.superview!.left + 20
            topStackView.right == topStackView.superview!.right - 20
            topStackView.height == 40
        }

        scrollView.addSubview(bottomStackView)
        constrain(bottomStackView, topStackView) { bottomStackView, topStackView in
            bottomStackView.top == topStackView.bottom + 10
            bottomStackView.left == bottomStackView.superview!.left + 20
            bottomStackView.height == 40
        }
    }

    func reloadView() {
        setupUI()
    }

    private func makeButtons(withTitles titles: [String]) -> [UIButton] {
        var buttonArray = [UIButton]()

        titles.forEach {
            let button = UIButton()
            button.setTitle("   \($0)   ", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = R.color.customLightGray()
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            buttonArray.append(button)
        }

        return buttonArray
    }

    @objc private func buttonClicked(sender: UIButton) {
        if let searchTerm = sender.titleLabel?.text?.trimmingCharacters(in: .whitespaces) {
            delegate?.tagDidClicked(self, tagText: searchTerm)
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
