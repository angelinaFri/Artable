//
//  UserService.swift
//  Artable
//
//  Created by Angelina on 6/30/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let UserService = _Userservice()

final class _Userservice {

    var user = User()
    var favorites = [Product]()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    // will listen to changes
    var userListener: ListenerRegistration? = nil
    var favListener: ListenerRegistration? = nil
    // for controlling restrictions for guests users
    var isGuest: Bool {
        guard let authUser = auth.currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }

    // this func will get current user's info and favorites
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        let userRef = db.collection("users").document(authUser.uid)

        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            // if success -> parse out data and itialize user object from it & set
            // it to this local user object

            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            print(self.user)
        })

        let favsRef = userRef.collection("favorites") //subcollection
        favListener = favsRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }

            //iteration
            snap?.documents.forEach({ (document) in
            //creating new products for appending them
            //to local favorites array -> var favorites = [Product]()
                let favorite = Product.init(data: document.data())
                self.favorites.append(favorite)
            })
        })
    }

    func favoriteSelected(product: Product) {
        let favsRef = Firestore.firestore().collection("users").document(user.id).collection("favorites")

        if favorites.contains(product) {
            //we remove it as a favorite
            favorites.removeAll{ $0 == product }
            // $0 -> any product in the favorites that is equal to the product
            // that has been selectet will be removed
            favsRef.document(product.id).delete()
            // deleting from the user's favorites subcollection
        } else {
            //add as a favorite
            favorites.append(product) // to local collection
            let data = Product.modelToData(product: product) // as a new doc to subcollection
            favsRef.document(product.id).setData(data)
        }

    }

    func logoutUser() {
        //reset some defaults here
        userListener?.remove()
        userListener = nil
        favListener?.remove()
        favListener = nil
        user = User()
        favorites.removeAll()
    }
}

