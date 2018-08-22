//
//  UserDefaults+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 22/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func widgetSharedUserDefaults() -> UserDefaults {
        return UserDefaults(suiteName: Constants.UserDefaults.sharedSuiteName)!
    }
}
