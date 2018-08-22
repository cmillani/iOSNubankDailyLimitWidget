//
//  NubankServices.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

class NubankServices {
    
    // Private init to avoid initializations for this static class
    private init() { }

    /// Validates if there is a valid session. If there is not, we need to ask user for username and password to retrieve nubank data
    ///
    /// - Returns: true if there is a valid session within the app
    static func IsValidSession() -> Bool {
        // Creates keychain query
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecAttrPath as String: Constants.Keychain.discoveryPathAttribute,
                                    kSecReturnData as String: true]
        // Executes query on keychain to retrieve credentials
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        // Validates query result
        if status != errSecSuccess {
            return false
        } else {
            return true
        }
    }
    
    /// Performs the login of the user on the platform, saving the credentials on keychain for next uses
    ///
    /// - Parameters:
    ///   - username: nubank username
    ///   - password: nubank password
    static func Login(cpf: String, password: String, success: (() -> Void)?, error: ((Error) -> Void)?) {
        // Tries to login on the server
        QueueManager.sharedInstance.execute(mechanism: {
            _ = try NubankServer.shared.login(cpf: cpf, password: password)
        }, success: success, error: error)
    }
    
    /// Gets the total amount of money that was spent today.
    ///
    /// - Returns: return array of all purchases made this month
    static func getAllPurchases(success: (([Purchase]) -> Void)?, error: ((Error) -> Void)?) {
        // Executes the server mechanism to retrieve all purchases from the server
        QueueManager.sharedInstance.execute(mechanism: NubankServer.shared.getAllPurchases, success: success, error: error)
    }
}
