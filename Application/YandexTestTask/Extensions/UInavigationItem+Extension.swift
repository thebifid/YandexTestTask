//
//  UInavigationItem+Extension.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import UIKit

/// Allows set title and subtitle on navigation bar
extension UINavigationItem {
    func setTitle(title: String, subtitle: String) {
        let one = UILabel()
        one.text = title
        one.font = R.font.montserratBold(size: 18)
        one.sizeToFit()

        let two = UILabel()
        two.text = subtitle
        two.font = R.font.montserratMedium(size: 12)
        two.textAlignment = .center
        two.sizeToFit()

        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center

        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)

        one.sizeToFit()
        two.sizeToFit()

        titleView = stackView
    }
}
