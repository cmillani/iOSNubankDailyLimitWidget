//
//  NubankPlannerError.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

enum NubankPlannerError: Error {
    case keychainSavingError
    case keychainNotFound
    
    case authError
    case emptyResponse
    case serverErrorWithInvalidRequestOrResponse
    case serverErrorStatusCode(httpCode: Int)
    
    case noBudgetSet
}
