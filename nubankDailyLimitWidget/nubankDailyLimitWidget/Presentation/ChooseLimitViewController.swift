//
//  ViewController.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 18/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

class ChooseLimitViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var monthlyLimitField: UITextField!
    @IBOutlet weak var dailyLimitField: UITextField!
    
    // MARK: - Properties
    private var currentLimit: Double?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setups UI
        self.setupUI()
        self.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginIfNecessary()
    }
}

// MARK: - Actions
extension ChooseLimitViewController {
    
    /// Hides the keyboard
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - UITextField Delegate
extension ChooseLimitViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Tries to convert the textField values to a Double
        if let doubleValue: Double = Double(textField.text ?? "") {
            // Checks if the field being edited is the monthly or daily budget and updates accordingly
            if textField == monthlyLimitField {
                BudgetServices.updateMonthlyLimit(doubleValue)
            } else {
                BudgetServices.updateMonthlyLimit(doubleValue * Double(Calendar.current.daysInCurrentMonth()))
            }
            // Reloads the UI with new data
            self.setupData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Ends edition, hiding keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Private Methods
extension ChooseLimitViewController {
    // Setups UI configuration, delegates and parameters
    private func setupUI() {
        // Setup delegetes of all fields
        self.monthlyLimitField.delegate = self
        self.dailyLimitField.delegate = self
        // Setups keyboard for text fields
        self.monthlyLimitField.keyboardType = UIKeyboardType.asciiCapableNumberPad
        self.dailyLimitField.keyboardType = UIKeyboardType.asciiCapableNumberPad
        // Adds tap to current VC to dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    // Fills UI with data source
    private func setupData() {
        // Gets previously saved budget limit
        self.currentLimit = BudgetServices.getMonthlyLimit()
        if let unwrappedLimit = self.currentLimit {
            // Setup fields with previous limit
            self.monthlyLimitField.text = String(unwrappedLimit)
            self.dailyLimitField.text = String(unwrappedLimit / Double(Calendar.current.daysInCurrentMonth()))
        }
    }
    
    private func loginIfNecessary() {
        if !NubankServices.IsValidSession() {
            self.performSegue(withIdentifier: "showLoginViewSegue", sender: nil)
        }
    }
    
}
