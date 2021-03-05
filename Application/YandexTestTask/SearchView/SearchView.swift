//
//  SearchView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 05.03.2021.
//

import Cartography
import UIKit

class SearchView: UIView, TagsViewDataSource {
    private var tagsArray = ["Apple", "Yandex", "Alibaba", "Facebook", "AMD", "Bank Of America", "Nokia", "Miscrosoft", "First Solar"] {
        didSet {
            popularRequestsTagView.reloadView()
        }
    }

    func titleForHeader(_ tagView: TagsView) -> String {
        return "Popular requests"
    }

    func titlesForButtons(_ tagView: TagsView) -> [String] {
        return tagsArray
    }

    // MARK: - Public Methods

    func setTags(withTags tags: [String]) {
        tagsArray = tags
    }

    // MARK: - UI Controls

    private let popularRequestsTagView = TagsView()

    // MARK: - Private Methods

    private func setupUI() {
        backgroundColor = .white
        popularRequestsTagView.dataSource = self
        addSubview(popularRequestsTagView)
        constrain(popularRequestsTagView) { view in
            view.top == view.superview!.safeAreaLayoutGuide.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.height == 150
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
