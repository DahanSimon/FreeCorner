//
//  Users.swift
//  FreeCorner
//
//  Created by Simon Dahan on 10/12/2021.
//

import Foundation
import Firebase

struct User {
    let offersRef = Database.database().reference().child("users").child("offers")
    var key: String = ""
    let name: String
    let phone: String
    var offers: [String: String]?
    var address: [String: String]
    var email: String?
    
    // MARK: Initialize with Raw Data
    init(name: String, phone: String, offer: [String: String], address: [String: String], email: String, key: String = "") {
        self.name    = name
        self.phone   = phone
        self.offers  = offer
        self.address = address
        self.email   = email
        self.key     = key
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.offers == rhs.offers, lhs.address == rhs.address,
           lhs.name == rhs.name, lhs.email == rhs.email, lhs.phone == rhs.phone {
            return true
        }
        return false
    }
}
