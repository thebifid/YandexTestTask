//
//  MenuBar.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.02.2021.
//

import Cartography
import UIKit

class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Private Properties

    private var labels = [String]()

    // MARK: - Public Properties

    weak var stocksController: StocksViewController?

    // MARK: - UI Controls

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    // MARK: - UI Actions

    private func setupUI() {
        backgroundColor = .white

        addSubview(collectionView)
        constrain(collectionView) { collectionView in
            collectionView.edges == collectionView.superview!.edges
        }

        collectionView.register(MenuBarCell.self, forCellWithReuseIdentifier: "cellId")
    }

    // MARK: Public Methods

    func setupCells(labels: [String]) {
        self.labels = labels
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MenuBarCell
        cell.setupCell(label: labels[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.collectionViewLayout.invalidateLayout()
        stocksController?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
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
