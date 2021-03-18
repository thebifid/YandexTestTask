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

    func addSignToEnd(currency: String, extraWord: String = "") -> String {
        var newString = self

        if !extraWord.isEmpty {
            newString.append(" \(extraWord)")
        }

        if currency == "USD" {
            newString.append(" $")
        } else if currency == "RUB" {
            newString.append(" ₽")
        } else {
            newString.append(" ¤")
        }

        return newString
    }

    func addPercent() -> String {
        var newString = self
        newString.append(" %")
        return newString
    }
}
