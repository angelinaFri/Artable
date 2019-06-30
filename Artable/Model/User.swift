//
//  User.swift
//  Artable
//
//  Created by Angelina on 6/30/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation

struct User {
    var id: String
    var email: String
    var username: String
    var stripeId: String

    //default initializer
    init(id: String = "",
         email: String = "",
         username: String = "",
         stripeId: String = "") {

        self.id = id
        self.email = email
        self.username = username
        self.stripeId = stripeId
    }

    //initializer when we get the data back from Firestore ->
    //we convert a dictionary into an instance of User

    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        username = data["username"] as? String ?? ""
        stripeId = data["stripeId"] as? String ?? ""
    }

    //taking an instance of the model and convert it to a dictionary for uploading as
    //a Firestore document

    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "stripeId": user.stripeId
        ]
        return data
    }

}
