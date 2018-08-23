//
//  Constants.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 22/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

struct Constants {

    /// User Defaults contants
    struct UserDefaults {
        static let sharedSuiteName: String = "group.nubankPlanner"
        static let monthlyLimitKey: String = "MONTHLY_LIMIT_KEY"
        static let loginUrlKey: String = "LOGIN_URL_KEY"
        static let cachedBudgetKey: String = "CACHED_BUDGET_KEY"
    }
    
    /// Keychain constants
    struct Keychain {
        static let discoveryPathAttribute: String = "api/discovery"
        static let proxyPathAttribute: String = "api/proxy"
        static let sharedAccessGroup: String = "WUMTT3EPGZ.br.com.cadumillani.nubankDailyLimitWidget"
    }
    
    static let budgetCacheValidityInSeconds: Double = 60 * 5
    
}
