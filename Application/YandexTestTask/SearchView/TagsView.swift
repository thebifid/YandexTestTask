//
//  TagsView.swift
//  TestyingCartography
//
//  Created by Vasiliy Matveev on 05.03.2021.
//

import Cartography
import MaterialComponents.MDCActivityIndicator
import UIKit

protocol TagsViewDataSource: AnyObject {
    func titleForHeader(_ tagView: TagsView) -> String
    func titlesForButtons(_ tagView: TagsView) -> [String]
}

protocol TagsViewDelegate: AnyObject {
    func tagDidClicked(_ tagView: TagsView, tagText text: String)
    func refreshButtonClicked(_ tagview: TagsView)
}

/// Subview for SearchView
class TagsView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    // MARK: - UI Controls

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

    private let emptyPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "List is empty for now"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .lightGray
        return label
    }()

    private let activityIndicator: MDCActivityIndicator = {
        let ai = MDCActivityIndicator()
        return ai
    }()

    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.refresh(), for: .normal)
        return button
    }()

    private let topStackView = UIStackView()
    private let bottomStackView = UIStackView()

    // MARK: - Public Properties

    weak var delegate: TagsViewDelegate?
    var type: TagsViewType = .local

    weak var dataSource: TagsViewDataSource? {
        didSet {
            setupUI()
        }
    }

    enum TagsViewType {
        case internet, local
    }

    // MARK: - Private Methods

    @objc private func refreshButtonTapped() {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        delegate?.refreshButtonClicked(self)
    }

    private func setupRefreshButton() {
        scrollView.addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        refreshButton.isHidden = true
        constrain(refreshButton) { refreshButton in
            refreshButton.center == refreshButton.superview!.center
            refreshButton.height == 40
            refreshButton.width == 40
        }
    }

    private func setupTags() {
        let arrayOfTitles = dataSource?.titlesForButtons(self)
        guard let unwrapArrayOfTitles = arrayOfTitles else { return }

        if unwrapArrayOfTitles.isEmpty {
            activityIndicator.stopAnimating()
            refreshButton.isHidden = false
        }

        guard !unwrapArrayOfTitles.isEmpty else { return }
        activityIndicator.stopAnimating()
        emptyPlaceholderLabel.alpha = 0
        var topArrayTitles = [String]()
        var bottomArrayTitles = [String]()

        if unwrapArrayOfTitles.count < 6 {
            topArrayTitles = unwrapArrayOfTitles
        } else {
            for index in stride(from: 0, to: unwrapArrayOfTitles.count, by: 2) {
                topArrayTitles.append(unwrapArrayOfTitles[index])
                if index + 1 < unwrapArrayOfTitles.count {
                    bottomArrayTitles.append(unwrapArrayOfTitles[index + 1])
                }
            }
        }

        let topArrayButtons = makeButtons(withTitles: topArrayTitles)
        let bottomArrayButtons = makeButtons(withTitles: bottomArrayTitles)

        topArrayButtons.forEach { topStackView.addArrangedSubview($0) }
        bottomArrayButtons.forEach { bottomStackView.addArrangedSubview($0) }
    }

    private func makeButtons(withTitles titles: [String]) -> [UIButton] {
        var buttonArray = [UIButton]()

        titles.forEach {
            let button = UIButton()
            button.setTitle("   \($0)   ", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = R.color.customLightGray()
            button.titleLabel?.font = R.font.montserratMedium(size: 14)
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

    // MARK: - Public Methods

    func setICStatus(status: Bool) {
        if status, !dataSource!.titlesForButtons(self).isEmpty {
            refreshButton.isHidden = true
        } else {
            refreshButton.isHidden = false
            activityIndicator.stopAnimating()
        }
    }

    func reloadData() {
        setupTags()
    }

    func addTag(withTag tag: String) {
        if emptyPlaceholderLabel.alpha == 1 {
            emptyPlaceholderLabel.alpha = 0
        }
        if bottomStackView.subviews.count < topStackView.subviews.count, topStackView.subviews.count > 5 {
            bottomStackView.addArrangedSubview(makeButtons(withTitles: [tag]).first!)
        } else {
            topStackView.addArrangedSubview(makeButtons(withTitles: [tag]).first!)
        }
    }

    // MARK: - UI Actions

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

    private func initSetup() {
        switch type {
        case .local:
            addSubview(emptyPlaceholderLabel)
            constrain(emptyPlaceholderLabel) { emptyPlaceholderLabel in
                emptyPlaceholderLabel.center == emptyPlaceholderLabel.superview!.center
            }
        case .internet:
            setupRefreshButton()
            addSubview(activityIndicator)
            constrain(activityIndicator) { ai in
                ai.center == ai.superview!.center
            }
            activityIndicator.startAnimating()
        }
    }

    // MARK: - Init

    init(type: TagsViewType) {
        super.init(frame: .zero)
        self.type = type
        initSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
