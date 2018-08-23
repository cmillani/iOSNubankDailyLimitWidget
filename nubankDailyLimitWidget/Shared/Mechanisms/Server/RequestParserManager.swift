//
//  RequestParserManager.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 21/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestParserManager {
    private init() { }
    
    /// Creates a login request
    ///
    /// - Parameters:
    ///   - cpf: cpf of the user to be logged
    ///   - password: password for this CPF
    /// - Returns: data to be sent for the server for the login request
    /// - Throws: if there is a problem parsing the JSON to Data
    static func parseLoginRequest(cpf: String, password: String) throws -> Data {
        var loginJSON = JSON()
        
        loginJSON["login"].stringValue = cpf
        loginJSON["password"].stringValue = password
        loginJSON["grant_type"].stringValue = "password"
        loginJSON["client_id"].stringValue = "other.conta"
        loginJSON["client_secret"].stringValue = "yQPeLzoHuJzlMMSAjC-LgNUJdUecx8XO"
        
        return try loginJSON.rawData()
    }
}
