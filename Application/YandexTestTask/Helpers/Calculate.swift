//
//  Calculate.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 10.03.2021.
//

import UIKit

class Calculate {
    static func calculateDailyChange(currency: String, currentPrice: Double, openPice: Double) -> NSAttributedString {
        let dailyChange = round(100 * (openPice - currentPrice)) / 100
        var color = UIColor.gray

        var resultString = ""
        if dailyChange > 0 {
            color = R.color.customGreen()!
            if currency == "USD" {
                resultString = "+$\(dailyChange)"
            } else {
                resultString = "+\(dailyChange) Р"
            }
        } else {
            color = .red
            if currency == "USD" {
                resultString = "-$\(abs(dailyChange))"
            } else {
                resultString = "-\(abs(dailyChange)) Р"
            }
        }

        var percentDailyChange = abs(openPice - currentPrice) / openPice * 100
        percentDailyChange = round(100 * percentDailyChange) / 100
        resultString = "\(resultString) (\(percentDailyChange)%)"
        return NSAttributedString(string: resultString,
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
