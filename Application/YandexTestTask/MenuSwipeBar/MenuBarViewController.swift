//
//  MenuBar.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

protocol MenuBarDataSource {
    func menuBar(_ menuBar: MenuBarViewController, titleForPageAt index: Int) -> String
    func menuBar(_ menuBar: MenuBarViewController, viewControllerForPageAt index: Int) -> UIViewController
    func numberOfPages(in swipeMenu: MenuBarViewController) -> Int
}

class MenuBarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Private Properties

    private var labels = [String]()

    // MARK: - Public Properties

    var dataSource: MenuBarDataSource?

    var startElement: Int = 0
    var barItemFontSize: CGFloat = 18

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Controls

    lazy var barCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 0
        return cv
    }()

    lazy var contentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 1
        cv.isPagingEnabled = true
        cv.allowsSelection = false
        return cv
    }()

    // MARK: - UI Actions

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(barCollectionView)
        constrain(barCollectionView) { collectionView in
            collectionView.top == collectionView.superview!.safeAreaLayoutGuide.top + 10
            collectionView.left == collectionView.superview!.left
            collectionView.right == collectionView.superview!.right
            collectionView.height == 60
        }

        view.addSubview(contentCollectionView)
        constrain(contentCollectionView, barCollectionView) { contentCollectionView, barCollectionView in
            contentCollectionView.top == barCollectionView.bottom
            contentCollectionView.left == contentCollectionView.superview!.left
            contentCollectionView.right == contentCollectionView.superview!.right
            contentCollectionView.bottom == contentCollectionView.superview!.bottom
        }

        barCollectionView.register(MenuBarCell.self, forCellWithReuseIdentifier: "barId")
        contentCollectionView.register(MenuContentCell.self, forCellWithReuseIdentifier: "contentId")
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barId", for: indexPath) as! MenuBarCell
            cell.setupCell(label: dataSource?.menuBar(self, titleForPageAt: indexPath.item) ?? "", fontSize: barItemFontSize)

            if indexPath.item == startElement {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentId", for: indexPath) as! MenuContentCell
            cell.boss = self
            cell.setupCell(withController: dataSource?.menuBar(self, viewControllerForPageAt: indexPath.item) ?? UIViewController())
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            return .init(width: contentCollectionView.frame.width, height: contentCollectionView.frame.height)
        }
        return .init(width: 100, height: 40)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.tag == 1 {
            let index = Int(targetContentOffset.pointee.x / view.frame.width)
            let indexPath = IndexPath(item: index, section: 0)
            barCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
