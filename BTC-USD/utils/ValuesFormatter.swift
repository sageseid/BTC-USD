//
//  ValuesFormatter.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct ValuesFormatter {
    static let volumeFormat = format(maximumFractionDigits: 1, positivePrefix: "", negativePrefix: "", numberStyle: .decimal, minimumFractionDigits: 1)
    static let changesFormat = format(maximumFractionDigits: 5, positivePrefix: "\u{2197}", negativePrefix: "\u{2199}", numberStyle: .decimal, minimumFractionDigits: 3)
    static let amountFormat = format( maximumFractionDigits: 5, positivePrefix: "", negativePrefix: "", numberStyle: .decimal, minimumFractionDigits: 1)
    static let priceFormat = format(maximumFractionDigits: 1, positivePrefix: "$", negativePrefix: "$", numberStyle: .currency, minimumFractionDigits: 1)
    
    static func double(from string: String) -> Double? {
        return NumberFormatter().number(from: string)?.doubleValue
    }
    
    static func format( maximumFractionDigits: Int, positivePrefix:String, negativePrefix: String , numberStyle: NumberFormatter.Style, minimumFractionDigits: Int  ) -> NumberFormatter {
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 1
            formatter.numberStyle = numberStyle
            formatter.maximumFractionDigits = maximumFractionDigits
            formatter.minimumFractionDigits = minimumFractionDigits
            formatter.positivePrefix = positivePrefix
            formatter.negativePrefix = negativePrefix
            return formatter
        }
    
    
}

