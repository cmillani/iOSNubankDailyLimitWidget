//
//  Calendar+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 18/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import UIKit

extension Calendar {

    /// Returns the total number of days in the current month
    static func daysInCurrentMonth() -> Int {
        return self.current.range(of: .day, in: .month, for: Date())!.count
    }

}
