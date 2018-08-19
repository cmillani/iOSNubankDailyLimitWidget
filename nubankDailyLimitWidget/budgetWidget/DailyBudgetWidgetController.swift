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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if !NubankServices.IsValidSession() {
            self.performSetupButton.isHidden = false
            self.todaysLimitLabel.isHidden = true
        } else {
            if let dailyBudget: Double = BudgetServices.getMonthlyLimit() {
                self.todaysLimitLabel.text = String(dailyBudget / Double(Calendar.daysInCurrentMonth()))
            } else {
                self.todaysLimitLabel.isHidden = true
                self.performSetupButton.setTitle("Hey, me fala o seu limite!", for: .normal)
                self.performSetupButton.isHidden = false
            }
        }
    }
}
