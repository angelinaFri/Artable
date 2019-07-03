//
//  StripeApi.swift
//  Artable
//
//  Created by Angelina on 7/3/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation
import Stripe
import FirebaseFunctions

class _StripeApi: NSObject, STPCustomerEphemeralKeyProvider {

    // for creating customer key to contact and then invoke our cloud function
    // on the backend.
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {

        let data = [
            "stripe_version": apiVersion,
            "customer_id": UserService.user.stripeId
        ]

        // `createEphemeralKey` - the name of backend function
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }

            guard let key = result?.data as? [String:Any] else {
                completion(nil, nil)
                return
            }
            completion(key, nil)
        }
    }
}


