//
//  UIViewController+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Presents a UIAlertController with given title and message
    ///
    /// - Parameters:
    ///   - title: title of the alert
    ///   - message: body message of the controller
    func presentAlert(title: String, message: String) {
        // Creates the alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // Adds confirmation button
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        // Presents the alert
        self.present(alert, animated: true, completion: nil)
    }
}
