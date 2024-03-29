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
    func refreshButtonClicked(_ searchView: SearchView)
}

/// Shows when user click on searchBar. Contains 2 subviews (Popular requests and Already searched Terms)
class SearchView: UIView, TagsViewDataSource, TagsViewDelegate {
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

    // MARK: - Private Properties

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

    // MARK: - Public Properties

    weak var delegate: SearchViewDelegate?

    // MARK: - Public Methods

    func tagDidClicked(_ tagView: TagsView, tagText text: String) {
        delegate?.searchView(self, didClickTag: text)
    }

    func refreshButtonClicked(_ tagview: TagsView) {
        delegate?.refreshButtonClicked(self)
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

    func setPopularTags(tags: [String]) {
        popularTagsArray = tags
    }

    func setSearchedTags(tags: [String]) {
        searchedTagsArray = tags
    }

    func addTag(withTag tag: String) {
        searchedRequestsTagView.addTag(withTag: tag)
    }

    func setICStatus(status: Bool) {
        popularRequestsTagView.setICStatus(status: status)
    }

    // MARK: - UI Actions

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
