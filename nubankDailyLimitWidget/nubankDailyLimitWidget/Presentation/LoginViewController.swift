//
//  LoginViewController.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Always clears password field when selected
        if textField == self.passwordField {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.performLogin()
        }
        return true
    }
}

// MARK: - Private Methods
extension LoginViewController {
    private func setupUI() {
        // Setups password field
        self.passwordField.textContentType = UITextContentType.password
        self.passwordField.isSecureTextEntry = true
        self.passwordField.keyboardType = UIKeyboardType.alphabet
        self.passwordField.delegate = self
        
        // Setups username field
        self.usernameField.textContentType = UITextContentType.username
        self.usernameField.keyboardType = UIKeyboardType.asciiCapableNumberPad
        self.usernameField.delegate = self
    }
    
    private func performLogin() {
        // Gets username and password from fields
        if let password = self.passwordField.text, let username = self.usernameField.text {
            // Validates that both are not empty
            guard !password.isEmpty && !username.isEmpty else {
                // For now, there is no action if there is a missing field
                return
            }
            
            NubankServices.Login(username: username, password: password, success: {
                // On Success, return to previous controller
                self.dismiss(animated: true, completion: nil)
            }, error: { error in
                // Display an error message
                self.presentAlert(title: "Opsie", message: "Ocorreu algum erro ao fazer o login! Confere os dados e tenta de novo ;)")
            })
        }
    }
}
