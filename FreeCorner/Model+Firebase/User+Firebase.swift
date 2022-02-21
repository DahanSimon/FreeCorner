//
//  User+Firebase.swift
//  FreeCorner
//
//  Created by Simon Dahan on 15/02/2022.
//

import Foundation
import Firebase

extension User {
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value   = snapshot.value as? [String: AnyObject],
            let name    = value["name"] as? String,
            let phone   = value["phone"] as? String,
            let offers  = value["offers"] as? [String: String]?,
            let email   = value["email"] as? String?,
            let address = value["address"] as? [String: String]
        else {
            return nil
        }
        self.name = name
        self.phone = phone
        self.offers = offers
        self.email = email
        self.address = address
        self.key = snapshot.key
    }
}
