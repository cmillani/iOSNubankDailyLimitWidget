//
//  BudgetServices.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 18/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

class BudgetServices {
    
    // Private init to avoid initializations for this static class
    private init () { }

    /// Updates the current monthly limit for the user
    ///
    /// - Parameter limit: new monthly limit
    static func updateMonthlyLimit(_ limit: Double) {
        // Uses user defaults to save double limit
        UserDefaults.widgetSharedUserDefaults().set(limit, forKey: Constants.UserDefaults.monthlyLimitKey)
        UserDefaults.widgetSharedUserDefaults().synchronize()
    }
    
    
    /// Gets the current defined monthly limit for the user
    ///
    /// - Returns: the limit or nil if none set
    static func getMonthlyLimit() -> Double? {
        // Retrieves saved limit from user defauts
        return UserDefaults.widgetSharedUserDefaults().value(forKey: Constants.UserDefaults.monthlyLimitKey) as? Double
    }
}
