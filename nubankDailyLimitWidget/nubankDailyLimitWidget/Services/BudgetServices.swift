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
    private static let limitUserDefaultsKey: String = "MONTHLY_LIMIT_KEY"

    /// Updates the current monthly limit for the user
    ///
    /// - Parameter limit: new monthly limit
    static func updateMonthlyLimit(_ limit: Double) {
        // Uses user defaults to save double limit
        UserDefaults.standard.set(limit, forKey: limitUserDefaultsKey)
    }
    
    
    /// Gets the current defined monthly limit for the user
    ///
    /// - Returns: the limit or nil if none set
    static func getMonthlyLimit() -> Double? {
        // Retrieves saved limit from user defauts
        return UserDefaults.standard.value(forKey: limitUserDefaultsKey) as? Double
    }
}
