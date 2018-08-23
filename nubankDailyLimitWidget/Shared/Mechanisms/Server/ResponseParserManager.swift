//
//  ResponseParserManager.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 20/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation
import SwiftyJSON

class ResponseParserManager {
    private init() { }
    
    /// Retrieves the login URL from the discovery response
    ///
    /// - Parameter discoveryResponse: response from the discovery request
    /// - Returns: the login url to be used
    static func parseLoginUrlFromDiscoveryResponse(_ discoveryResponse: String) -> String {
        let discoveryJSON: JSON = JSON(parseJSON: discoveryResponse)
        
        // Gets the login url from the discovery response and returns
        return discoveryJSON["login"].stringValue
    }
    
    /// Gets session information from the login response
    ///
    /// - Parameter loginResponse: response from the login request
    /// - Returns: Session data with token and urls for other requests
    static func parseSessionDataFromLogin(_ loginResponse: String) -> SessionData {
        let sessionJSON: JSON = JSON(parseJSON: loginResponse)
        
        // Extracts useful information from the login response and saves the session data
        let accessToken: String = sessionJSON["access_token"].stringValue
        let tokenType: String = sessionJSON["token_type"].stringValue
        let eventsUrl: String = sessionJSON["_links"]["events"]["href"].stringValue
        
        // Builds model and returns
        return SessionData(accessToken: accessToken, tokenType: tokenType, eventsUrl: eventsUrl)
    }
    
    /// Parses a events API respone into an array of purchases
    ///
    /// - Parameter eventsResponse: response from the events API
    /// - Returns: array of all transactions parsed from the events api response
    static func parseEventsResponse(_ eventsResponse: String) -> [Purchase] {
        let eventsJSON: JSON = JSON(parseJSON: eventsResponse)
        
        // Array to be returned
        var purchases: [Purchase] = []
        
        // Loops every events in the array
        for event in eventsJSON["events"].arrayValue {
            // Extracts basic information
            let dateString: String = event["time"].stringValue
            let price: Double = event["amount"].doubleValue/100
            let category: String = event["category"].stringValue
            
            // Validates if this event is a transaction. For now we are only listening to
            guard category == "transaction" else {
                continue
            }
            
            // Creates a formatter to convert the date string into a Swift Date
            let dateFormatter = DateFormatter()
            // Configures format according to the one analyzed from the server response for transactions
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            // Use GMT timezone
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            // Tries to parse the string to date
            guard let date: Date = dateFormatter.date(from: dateString) else {
                // If error happened, log for debugging purposes
                print("Could not parse date \(dateString)")
                continue
            }
            // Appends the new parsed purchase
            purchases.append(Purchase(value: price, quotas: 0, date: date))
        }
        
        // Returns fully parsed array
        return purchases
    }
}
