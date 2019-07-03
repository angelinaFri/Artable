//
//  StripeCart.swift
//  Artable
//
//  Created by Angelina on 7/2/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation

let StripeCart = _StripeCart()

// this class will keep track of our products that have been added to the shopping cart.

final class _StripeCart {

    var cartItems = [Product]()
    private let stripeCreditCartCut = 0.029 // Stripe 2.9% fee for transaction
    private let flatFeeCents = 30
    var shippingFees = 0

    // variables for subtotal, processing fees, total
    // computed properties

    var subtotal: Int {
        var amount = 0
        for item in cartItems {
            let pricePennies = Int(item.price * 100)
            amount += pricePennies
        }
        return amount
    }

    var processingFees: Int {
        if subtotal == 0 {
            return 0
        }

        let sub = Double(subtotal)
        let feesAndSub = Int(sub * stripeCreditCartCut) + flatFeeCents
        return feesAndSub
    }

    var total: Int {
        return subtotal + processingFees + shippingFees
    }

    func addItemToCart(item: Product) {
        cartItems.append(item)
    }

    func removeItemFromCart(item: Product) {
        if let index = cartItems.firstIndex(of: item) {
            cartItems.remove(at: index)
        }
    }

    func clearCart() {
        cartItems.removeAll()
    }
}

