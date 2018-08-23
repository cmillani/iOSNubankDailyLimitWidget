//
//  Double+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 23/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

extension Double {
    
    /// Converts the current double value into a string representing it in brazilian reais
    ///
    /// - Returns: self value formatted as brazilian reais
    func toCurrency() -> String {
        // Creates the formatter
        let formatter: NumberFormatter = NumberFormatter()
        
        // Setup the minimum representation to be 0,00 (two digits after the decimal, one before)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        // Setups the brazilian separators stype
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        
        // Returns formatted string, with fallback to default string formatter
        return "R$ " + (formatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self))
    }
}
