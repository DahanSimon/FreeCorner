//
//  Offer+Firebase.swift
//  FreeCorner
//
//  Created by Simon Dahan on 15/02/2022.
//

import Foundation
import Firebase

extension Offer {
    // MARK: Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let description = value["description"] as? String,
            let images = value["images"] as? [String],
            let owner = value["owner"] as? String,
            let category = value["category"] as? String
        else {
            return nil
        }
        self.name = name
        self.desctiption = description
        self.images = images
        self.owner = owner
        self.category = category
        self.ref = snapshot.ref
        self.key = snapshot.key
    }
}
