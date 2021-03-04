//
//  MenuContentCell.swift
//  SwipeBar
//
//  Created by Vasiliy Matveev on 23.02.2021.
//

import Cartography
import UIKit

class MenuContentCell: UICollectionViewCell {
    weak var boss: MenuBarViewController?

    func setupCell(withController controller: UIViewController) {
        if let controller = controller as? BaseControllerWithTableView {
            controller.cellDidScrollDelegate = (boss as! CellDidScrollDelegate)
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
