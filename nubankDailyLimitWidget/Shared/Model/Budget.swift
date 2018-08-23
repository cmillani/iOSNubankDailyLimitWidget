//
//  Budget.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 23/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

struct Budget: Codable {
    var monthlyRemainings: Double
    var dailyRemainings: Double
    var monthlyBudget: Double
    var dailyBudget: Double
    var expirationDate: Date
}
