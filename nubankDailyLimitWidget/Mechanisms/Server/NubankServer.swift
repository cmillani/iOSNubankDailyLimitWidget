//
//  NubankServer.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

class NubankServer {
    
    static let shared: NubankServer = NubankServer()
    
    private init() {
        HTTPRequestManager.shared.tokenDataSource = self
    }
    
    private let discoveryUrl: String = "https://prod-s0-webapp-proxy.nubank.com.br/api/discovery"
    private let jsonContentType: String = "application/json"
    
    /// Retrieves all purchases from at least the current month
    ///
    /// - Returns: All retrieved purchases from the server
    /// - Throws: If there is a server or system error, it is thrown
    func getAllPurchases() throws -> [Purchase] {
        // Gets the url to be called
        let url: String = try getEventsUrl()
        
        // Hits the server
        let eventsResponse: String = try HTTPRequestManager.shared.request(toUrl: url, withBodyContentType: jsonContentType, withBody: nil, usingMethod: .get)
        
        // Parses and returns the data
        return ResponseParserManager.parseEventsResponse(eventsResponse)
    }
    
    /// Makes a login request to the server, saving the credentials and token on the keychain in case of success
    ///
    /// - Parameters:
    ///   - username: cpf of the user to be logged in
    ///   - password: password of the user to be logged in
    /// - Throws: If there is a request or system error, it is thrown
    func login(cpf: String, password: String, updatingKeychainData: Bool = true) throws -> SessionData {
        // Retrieves the request URL
        let url: String = try getLoginUrl()
        // Creates the login body
        let loginRequestBody: Data = try RequestParserManager.parseLoginRequest(cpf: cpf, password: password)
        // Executes the login request
        let loginResponse: String = try HTTPRequestManager.shared.request(toUrl: url, withBodyContentType: jsonContentType, withBody: loginRequestBody, usingMethod: .post, useToken: false)
        // Parses the session data from the login response
        let sessionData: SessionData = ResponseParserManager.parseSessionDataFromLogin(loginResponse)
        
        // If we should update the keychain, calls
        if updatingKeychainData {
            // First of all, always executes a delete query before saving a new password, in order to prevent duplicate errors
            let deleteQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                              kSecAttrPath as String: Constants.Keychain.discoveryPathAttribute]
            // Executes query on keychain to delete credentials
            _ = SecItemDelete(deleteQuery as CFDictionary)
            
            // Creates the query to save the user access data on the keychain
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: cpf,
                                        kSecValueData as String: password.data(using: String.Encoding.utf8)!,
                                        kSecAttrPath as String: Constants.Keychain.discoveryPathAttribute,
                                        kSecAttrAccessGroup as String: Constants.Keychain.sharedAccessGroup]
            // Saves the data
            let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
            // Verifies the status of the write to the keychain
            if status != errSecSuccess {
                throw NubankPlannerError.keychainSavingError
            }
        }
        
        // Returns
        return sessionData
    }
}

// MARK: Private methods

extension NubankServer {
    
    /// Retrieves a valid login url from the server or local cache
    ///
    /// - Returns: URL to be used to log the user in the app
    /// - Throws: If any error occurs during the proccess of obtaining the url, it is thrown
    private func getLoginUrl() throws -> String {
        // Verify if there is a cached login url in the user defaults
        if let currentLoginUrl = UserDefaults.widgetSharedUserDefaults().string(forKey: Constants.UserDefaults.loginUrlKey) {
            return currentLoginUrl
        } else {
            // If not, hit the discovery url to retrieve the login url
            let discoveryResponse: String = try HTTPRequestManager.shared.request(toUrl: discoveryUrl, withBodyContentType: jsonContentType, withBody: nil, usingMethod: .get, useToken: false)
            
            // Parses the discovery response for the login url
            let newLoginUrl: String = ResponseParserManager.parseLoginUrlFromDiscoveryResponse(discoveryResponse)
            
            // Caches the retrieved url
            UserDefaults.widgetSharedUserDefaults().set(newLoginUrl, forKey: Constants.UserDefaults.loginUrlKey)
            // Returns the newly parsed url
            return newLoginUrl
        }
    }
    
    /// Returns the events url, retrieving it from the server or returning a cached version
    ///
    /// - Returns: URL to be used to get all user events
    /// - Throws: If any error occurs during the proccess of obtaining the url, it is thrown
    private func getEventsUrl() throws -> String {
        // Tries to get a session from the app
        let newSessionData = try getSessionData()
        // Returns the events url from the session
        return newSessionData.eventsUrl
    }
    
    /// Gets the token to be used on the server request
    ///
    /// - Returns: Token to be used on the server request
    /// - Throws: If there is a server or system error while obtaining the token type, an error is thrown
    private func getNubankToken() throws -> String {
        // Tries to get a session from the app
        let newSessionData = try getSessionData()
        // Returns the saved access token
        return newSessionData.accessToken
    }
    
    /// Gets the token type to be used on the server request
    ///
    /// - Returns: Token Type to be used on the server request
    /// - Throws: If there is a server or system error while obtaining the token type, an error is thrown
    private func getNubankTokenType() throws -> String {
        // Tries to get a session from the app
        let newSessionData = try getSessionData()
        // Returns the saved token type
        return newSessionData.tokenType.capitalized
    }
    
    /// Method responsible for getting an OAuth token to be used into requests
    /// - Parameters:
    ///     - numberOfTries: number of tries on getting outh token
    /// - Returns: oauth token to be used in the requests
    /// - Throws: Exception indicating that it was not possible to achieve token
    private func getSessionData() throws -> SessionData {
        
        // Creates a query to search keychain for a saved userSession
        let userSessionQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                            kSecMatchLimit as String: kSecMatchLimitOne,
                                            kSecReturnAttributes as String: true,
                                            kSecAttrPath as String: Constants.Keychain.proxyPathAttribute,
                                            kSecReturnData as String: true]
        // Executes query on keychain to retrieve credentials
        var userSessionItem: CFTypeRef?
        let userSessionQueryStatus = SecItemCopyMatching(userSessionQuery as CFDictionary, &userSessionItem)
        
        if userSessionQueryStatus == errSecSuccess,
            let userSessionData: [String: Any] = userSessionItem as? [String: Any],
            let sessionDataData: Data = userSessionData[kSecValueData as String] as? Data,
            let savedSessionData: SessionData = try? JSONDecoder().decode(SessionData.self, from: sessionDataData) {
            return savedSessionData
        } else {
            // Creates keychain query to search for saved credentials
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnAttributes as String: true,
                                        kSecAttrPath as String: Constants.Keychain.discoveryPathAttribute,
                                        kSecReturnData as String: true]
            // Executes query on keychain to retrieve credentials
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            
            // Tries to parse credentials from keychain response
            guard status == errSecSuccess,
                let accountData: [String: Any] = item as? [String: Any],
                let cpf: String = accountData[kSecAttrAccount as String] as? String,
                let passwordData = accountData[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8)
                else {
                    // Essential data not found, throws error
                    throw NubankPlannerError.keychainNotFound
            }
            
            // Gets session data for retrieved credentials
            let sessionData: SessionData = try self.login(cpf: cpf, password: password, updatingKeychainData: false)
            
            // Parses session data struct into data and saves it on the keychain
            if let sessionDataData = try? JSONEncoder().encode(sessionData) {
                let sessionDataQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                                       kSecValueData as String: sessionDataData,
                                                       kSecAttrPath as String: Constants.Keychain.proxyPathAttribute,
                                                       kSecAttrAccessGroup as String: Constants.Keychain.sharedAccessGroup]
                // Exeutes query to cache newly obtained session data
                let _: OSStatus = SecItemAdd(sessionDataQuery as CFDictionary, nil)
            }
            
            // Returns session data obtained
            return sessionData
        }
    }
}

extension NubankServer: HTTPRequestTokenDataSource {
    func getToken() throws -> String? {
        // Returns token to be used on the request
        return try self.getNubankToken()
    }
    
    func getTokenType() throws -> String? {
        // Returns token type to be used on the request
        return try self.getNubankTokenType()
    }
    
    func renewToken() throws {
        // Deletes all used saved information
        let deleteQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                          kSecAttrPath as String: Constants.Keychain.proxyPathAttribute]
        // Executes query on keychain to delete credentials
        _ = SecItemDelete(deleteQuery as CFDictionary)
        
        // Deletes saved login url
        UserDefaults.widgetSharedUserDefaults().set(nil, forKey: Constants.UserDefaults.loginUrlKey)
    }
    
    
}
