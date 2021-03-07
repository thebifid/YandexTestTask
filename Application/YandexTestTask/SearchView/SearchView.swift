//
//  SearchView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 05.03.2021.
//

import Cartography
import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, didClickTag tag: String)
}

class SearchView: UIView, TagsViewDataSource, TagsViewDelegate {
    weak var delegate: SearchViewDelegate?

    func tagDidClicked(_ tagView: TagsView, tagText text: String) {
        delegate?.searchView(self, didClickTag: text)
    }

    private var popularTagsArray = [String]() {
        didSet {
            popularRequestsTagView.reloadData()
        }
    }

    private var searchedTagsArray = [String]() {
        didSet {
            searchedRequestsTagView.reloadData()
        }
    }

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

    func addTag(withTag tag: String) {
        searchedRequestsTagView.addTag(withTag: tag)
    }

    // MARK: - UI Controls

    private lazy var popularRequestsTagView: TagsView = {
        let tv = TagsView(type: .internet)
        tv.tag = 0
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    private lazy var searchedRequestsTagView: TagsView = {
        let tv = TagsView(type: .local)
        tv.tag = 1
        tv.dataSource = self
        tv.delegate = self
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
