//
//  SearchView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 05.03.2021.
//

import Cartography
import UIKit

class SearchView: UIView, TagsViewDataSource {
    private var popularTagsArray = [String]() {
        didSet {
            popularRequestsTagView.reloadView()
        }
    }

    private var searchedTagsArray = [String]()

    func titleForHeader(_ tagView: TagsView) -> String {
        if tagView.tag == 0 {
            return "Popular requests"
        } else {
            return "You've searched for this"
        }
    }

    func titlesForButtons(_ tagView: TagsView) -> [String] {
        if tagView.tag == 0 {
            return popularTagsArray
        } else {
            return searchedTagsArray
        }
    }

    // MARK: - Public Methods

    func setPopularTags(tags: [String]) {
        popularTagsArray = tags
    }

    func setSearchedTags(tags: [String]) {
        searchedTagsArray = tags
    }

    // MARK: - UI Controls

    private lazy var popularRequestsTagView: TagsView = {
        let tv = TagsView()
        tv.tag = 0
        tv.dataSource = self
        return tv
    }()

    private lazy var searchedRequestsTagView: TagsView = {
        let tv = TagsView()
        tv.tag = 1
        tv.dataSource = self
        return tv
    }()

    // MARK: - Private Methods

    private func setupUI() {
        backgroundColor = .white
        addSubview(popularRequestsTagView)
        constrain(popularRequestsTagView) { view in
            view.top == view.superview!.safeAreaLayoutGuide.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.height == 150
        }

        addSubview(searchedRequestsTagView)
        constrain(searchedRequestsTagView, popularRequestsTagView) { searched, popular in
            searched.top == popular.bottom
            searched.left == searched.superview!.left
            searched.right == searched.superview!.right
            searched.height == 150
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
