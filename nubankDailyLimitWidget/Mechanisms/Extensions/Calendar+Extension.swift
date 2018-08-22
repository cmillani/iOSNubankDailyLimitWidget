//
//  Calendar+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 18/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

extension Calendar {

    /// Returns the total number of days in the current month
    ///
    /// - Returns: total number of days for current month
    func daysInCurrentMonth() -> Int {
        return self.range(of: .day, in: .month, for: Date())!.count
    }
    
    /// Returns the amount of days remaining for this month to end
    ///
    /// - Returns: days until this month ends
    func remainingDaysInCurrentMonth() -> Int {
        // Get the current day with a 0 index style
        let currentDayInTheMonth: Int = self.component(.day, from: Date()) - 1 // First day is index 0
        // Subtract the current day index from the number of days of this month
        return self.range(of: .day, in: .month, for: Date())!.count - currentDayInTheMonth
    }

}
