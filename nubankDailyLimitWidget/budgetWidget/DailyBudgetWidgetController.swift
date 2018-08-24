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
    @IBOutlet weak var dailyBudgetBarView: UIView!
    @IBOutlet weak var monthlyBudgetBarView: UIView!
    @IBOutlet weak var dailyBudgetBarDistanceToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthlyBudgetBarDistanceToTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Tries to retrieve data form the server
        BudgetServices.getThisMonthRamainingBudget(success: { budget in
            if budget.expirationDate > Date() {
                // Data still valid, no need to update
                completionHandler(NCUpdateResult.noData)
            } else {
                // Expired data, need to recalculate and update UI
                completionHandler(NCUpdateResult.newData)
            }
        }, error: { error in
            // Error received
            completionHandler(NCUpdateResult.failed)
        })
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // All insets are configures in the storyboard, so we remove all system default insets
        return UIEdgeInsets.zero
    }
}

// MARK: - Private Methods

extension DailyBudgetWidgetController {
    
    /// Setup screen with adequate data
    private func setupUIData() {
        // To avoid showing placeholder information from the storyboard, clears all labels
        self.todaysLimitLabel.text = ""
        self.thisMonthLimitLabel.text = ""
        // Tries to retrieve valid budget data
        BudgetServices.getThisMonthRamainingBudget(success: { budget in
            // hides the error button
            self.performSetupButton.isHidden = true
            // shows values labels
            self.limitsStackView.isHidden = false
            // Could retrieve data, formats and shows relevant data
            self.todaysLimitLabel.text = budget.dailyRemainings.toCurrency()
            self.thisMonthLimitLabel.text = budget.monthlyRemainings.toCurrency()
            
            // Force all updates
            self.view.layoutIfNeeded()
            
            // Calculates the custom progress bar constraint to indicate how much can still be spent.
            // The constraint is from the top of the mutating view to the top of the container view
            // Calculating the remainings/budget indicates the progress, so subtracting it from one indicates the empty space (that is what the constraint controls), and then we can multiply it by the height of the view to obtain the contraint constant
            self.monthlyBudgetBarDistanceToTopConstraint.constant = CGFloat(1 - (budget.monthlyRemainings / budget.monthlyBudget)) * self.monthlyBudgetBarView.frame.height
            self.dailyBudgetBarDistanceToTopConstraint.constant = CGFloat(1 - (budget.dailyRemainings / budget.dailyBudget)) * self.dailyBudgetBarView.frame.height
            
            // Updates constraints, animating
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            
        }, error: { error in
            // Could not retrieve data, hides the budgets labels
            self.limitsStackView.isHidden = true
            // Shows the error label
            self.performSetupButton.isHidden = false
        })
    }
}
