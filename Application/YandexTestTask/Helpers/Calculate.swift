//
//  Calculate.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 10.03.2021.
//

import UIKit

class Calculate {
    static func calculateDailyChange(currency: String, currentPrice: Double, previousClose: Double) -> NSAttributedString {
        if currentPrice == 0, previousClose == 0 {
            return NSAttributedString(string: "0.0", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }

        let dailyChange = round(100 * (previousClose - currentPrice)) / 100
        var color = UIColor.gray

        var resultString = ""
        if dailyChange < 0 {
            color = R.color.customGreen()!
            resultString = "\(abs(dailyChange))".withCurrency(currency: currency, withSign: "+")
        } else {
            color = .red
            resultString = "\(abs(dailyChange))".withCurrency(currency: currency, withSign: "-")
        }

        var percentDailyChange = abs(previousClose - currentPrice) / previousClose * 100
        percentDailyChange = round(100 * percentDailyChange) / 100
        resultString = "\(resultString) (\(percentDailyChange)%)"
        return NSAttributedString(string: resultString,
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
