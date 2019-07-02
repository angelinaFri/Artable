//
//  Extensions.swift
//  Artable
//
//  Created by Angelina on 6/20/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isNotEmpty : Bool {
        return !isEmpty
    }
}

extension UIViewController {

    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension Int {

    func penniesToFormattedCurrency() -> String {
        // penny to dollars
        // `self` whatever value this func is being called on
        let dollars = Double(self) / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let dollarString = formatter.string(from: dollars as NSNumber) {
           return dollarString
        }
        return "$0.00"
    }
}

