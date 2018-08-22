//
//  TodayViewController.swift
//  budgetWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit
import NotificationCenter

class DailyBudgetWidgetController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var performSetupButton: UIButton!
    @IBOutlet weak var todaysLimitLabel: UILabel!
    @IBOutlet weak var thisMonthLimitLabel: UILabel!
    @IBOutlet weak var limitsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

// MARK: - Private Methods

extension DailyBudgetWidgetController {
    private func setupUIData() {
        // First of all, searches for a valid nubank session
        if !NubankServices.IsValidSession() {
            // No session available, indicates that the user needs to open the app in order to configure that
            self.performSetupButton.isHidden = false
            self.limitsStackView.isHidden = true
        } else {
            // There is a session, look for a selected monthly limit
            if let monthlyBudget: Double = BudgetServices.getMonthlyLimit() {
                self.setupExpensesLabels(monthlyBudget: monthlyBudget)
            } else {
                // If there is no monthly limit saved on the application, indicates to the user that it must select one in the application
                self.limitsStackView.isHidden = true
                self.performSetupButton.setTitle("Hey, me fala o seu limite!", for: .normal)
                self.performSetupButton.isHidden = false
            }
        }
    }
    
    /// Setups the expenses views
    ///
    /// - Parameter monthlyBudget: budget for this month
    private func setupExpensesLabels(monthlyBudget: Double) {
        // Tries to get all expenses from the server
        NubankServices.getAllPurchases(success: { (purchases) in
            // All information available, calculate remaining budget
            self.todaysLimitLabel.text = String((monthlyBudget / Double(Calendar.current.daysInCurrentMonth())) - self.getAllSpentToday(from: purchases))
            self.thisMonthLimitLabel.text = String(monthlyBudget - self.getAllSpentThisMonth(from: purchases))
        }) { (error) in
            // Error while getting expenses from server, notify user
            self.limitsStackView.isHidden = true
            self.performSetupButton.setTitle("Deu ruim parça :/", for: .normal)
            self.performSetupButton.isHidden = false
        }
        
    }
    
    /// From an array of expenses, gets the total spent on the current month
    ///
    /// - Parameter purchases: array of expenses to be looked at
    /// - Returns: total expent this month
    private func getAllSpentThisMonth(from purchases: [Purchase]) -> Double {
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
    func getAllSpentToday(from purchases: [Purchase]) -> Double {
        return purchases.filter({
            // Compare the day of the purchase and today
            let dateComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
            let currentDateComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            // Filter only purchases from today
            return dateComponents.year == currentDateComponents.year && dateComponents.month == currentDateComponents.month && dateComponents.day == currentDateComponents.day
        }).reduce(0.0, {$0 + $1.value})
    }
}
