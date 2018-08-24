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
    
    /// Forces recalculation of the monthly budget values, independant of the cache expiration date
    ///
    /// - Parameters:
    ///   - success: called with valid, newly calculated budget data
    ///   - error: if any server or system error occurs, this function is called with the error
    static func recalculateThisMonthRemainingBudget(success: ((Budget) -> Void)?, error: ((Error) -> Void)?) {
        // Executes server queries and calculations in a background queue and returns on the main thread
        QueueManager.sharedInstance.execute(mechanism: {
            return try recalculateThisMonthBudgets()
        }, success: success, error: error)
    }
    
    /// Retrieves a cached version or, if not available, retrieves expenses data from the server an calculates budget to return this month's values
    ///
    /// - Parameters:
    ///   - success: called upon success of this request, with a valid budget object
    ///   - error: if any server or system error occurs, this function is called with the error
    static func getThisMonthRamainingBudget(success: ((Budget) -> Void)?, error: ((Error) -> Void)?) {
        QueueManager.sharedInstance.execute(mechanism: {
            // Tries to retrieve cahced data
            guard let cachedBudgetData: Data = UserDefaults.widgetSharedUserDefaults().object(forKey: Constants.UserDefaults.cachedBudgetKey) as? Data,
                let cachedBudget: Budget = try? JSONDecoder().decode(Budget.self, from: cachedBudgetData) // Tries to parse data into budget object
            else {
                // If any of the conditions above is not ok, recalculates the budget and returns it
                return try recalculateThisMonthBudgets()
            }
            
            if cachedBudget.expirationDate <= Date() { // Validates the cache expiration of this budget calculation
                // If the value is invalid, will return the same way but triggers an update already, with the success validadion
                self.recalculateThisMonthRemainingBudget(success: success, error: nil)
            }
            
            // Could retrieve cached budget, returns it
            return cachedBudget
        }, success: success, error: error)
    }
    
    /// Forces a recalculation of the monthly budget values, independant of the cache expiration date
    ///
    /// - Returns: Newly calculated budget data
    /// - Throws:if any server or system error occurs, this function is called with the error
    private static func recalculateThisMonthBudgets() throws -> Budget {
        // Tries to retrieve user defined budget data
        guard let monthlyBudget: Double = BudgetServices.getMonthlyLimit() else {
            // Without this value, there is no way to calculate the budget, returns adequate error
            throw NubankPlannerError.noBudgetSet
        }
        // Retrieves expenses and filters into expenses from this month and today
        let expenses: [Purchase] = try NubankServer.shared.getAllPurchases()
        let thisMonthExpenses: Double = getAllSpentThisMonth(from: expenses)
        let todayExpenses: Double = getAllSpentToday(from: expenses)
        
        // Calculates average daily budget for everyday of the month
        let dailyBudget: Double = monthlyBudget/Double(Calendar.current.daysInCurrentMonth())
        
        // Calculates remaining values for the month, and based on that value how much could be expent each day until the end of the month
        let monthlyRemainings: Double = monthlyBudget - thisMonthExpenses
        let dailyRemainings: Double = monthlyRemainings/Double(Calendar.current.remainingDaysInCurrentMonth()) - todayExpenses
        
        // Creates budget object from the calculated values, with the default expiration time
        let budget: Budget = Budget(monthlyRemainings: monthlyRemainings, dailyRemainings: dailyRemainings, monthlyBudget: monthlyBudget, dailyBudget: dailyBudget, expirationDate: Date(timeIntervalSinceNow: Constants.budgetCacheValidityInSeconds))
        
        // Saves cached version of calculated budget
        UserDefaults.widgetSharedUserDefaults().set(try? JSONEncoder().encode(budget), forKey: Constants.UserDefaults.cachedBudgetKey)
        
        // Returns budget
        return budget
    }
    
    /// From an array of expenses, gets the total spent on the current month
    ///
    /// - Parameter purchases: array of expenses to be looked at
    /// - Returns: total expent this month
    private static func getAllSpentThisMonth(from purchases: [Purchase]) -> Double {
        // Filters all expenses from this month and reduces the value to a single double value
        return purchases.filter({
            // Compare the months of the purchase and the current month
            let dateComponents: DateComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
            let currentDateComponents: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
            // Filter only purchases from this month
            return dateComponents.year == currentDateComponents.year && dateComponents.month == currentDateComponents.month
        }).reduce(0.0, {$0 + $1.value})
    }
    
    /// From an array of expenses, gets the total spent on the current date
    ///
    /// - Parameter purchases: array of expenses to be looked at
    /// - Returns: total expent today
    private static func getAllSpentToday(from purchases: [Purchase]) -> Double {
        return purchases.filter({
            // Compare the day of the purchase and today
            let dateComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
            let currentDateComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            // Filter only purchases from today
            return dateComponents.year == currentDateComponents.year && dateComponents.month == currentDateComponents.month && dateComponents.day == currentDateComponents.day
        }).reduce(0.0, {$0 + $1.value})
    }
}
