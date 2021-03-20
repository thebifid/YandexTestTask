//
//  String+Extension.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 14.03.2021.
//

import Foundation

/// func withCurrency() = "100", "USD" -> "$100";  func addSignToEnd() =  "100" -> "100%"
extension String {
    func withCurrency(currency: String, withSign sign: String = "") -> String {
        var newString = ""

        if currency == "USD" {
            newString.append("$")
            newString.append(addSpaceIfNeeded())
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

    private func addSpaceIfNeeded() -> String {
        guard let intValue = Double(self) else { return "" }
        var result = self

        if intValue > 999, intValue < 9999 {
            result.insert(" ", at: result.index(result.startIndex, offsetBy: 1))
        } else if intValue > 9999 {
            result.insert(" ", at: result.index(result.startIndex, offsetBy: 2))
        }

        return result
    }
}
