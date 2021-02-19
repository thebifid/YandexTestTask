//
//  StocksViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import Cartography
import UIKit

class StocksViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - UI Controls

    private let searchController = UISearchController()
    private lazy var stockFavView = MenuBar()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white

        setupSearchBar()
        setupStockFavView()
        setupCollectionView()
        collectionView.contentInsetAdjustmentBehavior = .never //!
    }

    // MARK: - UI Actions

    private func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal

        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar

        definesPresentationContext = true
    }

    private func setupStockFavView() {
        view.addSubview(stockFavView)
        constrain(stockFavView) { stockFavView in
            stockFavView.left == stockFavView.superview!.left
            stockFavView.right == stockFavView.superview!.right
            stockFavView.top == stockFavView.superview!.safeAreaLayoutGuide.top
            stockFavView.height == 60
        }

        stockFavView.setupCells(labels: ["Stocks", "Favourite"])
        stockFavView.stocksController = self
    }

    func setupCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")

        constrain(collectionView, stockFavView) { cv, stockFavView in
            cv.top == stockFavView.bottom
            cv.left == cv.superview!.left
            cv.right == cv.superview!.right
            cv.bottom == cv.superview!.bottom
        }

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let color = [UIColor.white, UIColor.gray, UIColor.white, UIColor.gray, UIColor.white, UIColor.gray, UIColor.white, UIColor.gray]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        cell.backgroundColor = color[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        stockFavView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        stockFavView.collectionView(stockFavView.collectionView, didSelectItemAt: indexPath)
    }

    // MARK: - Init

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
