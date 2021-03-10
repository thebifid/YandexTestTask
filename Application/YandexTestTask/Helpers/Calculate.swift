//
//  Calculate.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 10.03.2021.
//

import UIKit

class Calculate {
    static func calculateDailyChange(currency: String, currentPrice: Double, previousClose: Double) -> NSAttributedString {
        let dailyChange = round(100 * (previousClose - currentPrice)) / 100
        var color = UIColor.gray

        var resultString = ""
        if dailyChange < 0 {
            color = R.color.customGreen()!
            if currency == "USD" {
                resultString = "+$\(abs(dailyChange))"
            } else {
                resultString = "+\(abs(dailyChange)) Р"
            }
        } else {
            color = .red
            if currency == "USD" {
                resultString = "-$\(abs(dailyChange))"
            } else {
                resultString = "-\(abs(dailyChange)) Р"
            }
        }

        var percentDailyChange = abs(previousClose - currentPrice) / previousClose * 100
        percentDailyChange = round(100 * percentDailyChange) / 100
        resultString = "\(resultString) (\(percentDailyChange)%)"
        return NSAttributedString(string: resultString,
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
