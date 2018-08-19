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
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
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
    static func Login(username: String, password: String, success: (() -> Void)?, error: ((Error) -> Void)?) {
        // First of all, always executes a delete query before saving a new password
        let deleteQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        // Executes query on keychain to delete credentials
        _ = SecItemDelete(deleteQuery as CFDictionary)
        
        // Creates the query to save the user access data on the keychain
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: username,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!,
                                    kSecAttrAccessGroup as String: "br.com.cadumillani.nubankDailyLimitWidget"]
        // Saves the data
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        // Verifies the status of the write to the keychain
        if status != errSecSuccess {
            // Case of error throw it to the caller
            error?(NubankPlannerError.keychainSavingError)
        } else {
            // No error, calls success handler
            success?()
        }
    }
}
