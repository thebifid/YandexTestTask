//
//  MenuContentCell.swift
//  SwipeBar
//
//  Created by Vasiliy Matveev on 23.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

/// ContentCell for MenyBarViewController
/// Тут я понимаю, что реализация через костыль, но если не добовалять как addChild, то потом возникают утечки памяти,
/// (не будет указателя на слабую ссылку)
class MenuContentCell: UICollectionViewCell {
    weak var boss: MenuBarViewController?
    weak var barCV: UICollectionView?

    func setupCell(withController controller: UIViewController) {
        if let controller = controller as? BaseControllerWithTableView {
            controller.barCV = barCV
        }
        boss?.addChild(controller)
        addSubview(controller.view)
        controller.didMove(toParent: boss)
        constrain(controller.view) { controller in
            controller.edges == controller.superview!.edges
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
