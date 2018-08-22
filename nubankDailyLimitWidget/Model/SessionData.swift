//
//  SessionData.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 21/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

struct SessionData: Codable {
    var accessToken: String
    var tokenType: String
    var eventsUrl: String
}
