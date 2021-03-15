//
//  String+Extension.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 14.03.2021.
//

import Foundation

extension String {
    func withCurrency(currency: String, withSign sign: String = "") -> String {
        var newString = ""

        if currency == "USD" {
            newString.append("$")
            newString.append(self)
        } else if currency == "RUB" {
            newString = self
            newString.append(" ₽")
        } else {
            newString.append("¤")
            newString.append(self)
        }

        if !sign.isEmpty {
            newString.insert(contentsOf: sign, at: newString.startIndex)
        }

        return newString
    }
}
