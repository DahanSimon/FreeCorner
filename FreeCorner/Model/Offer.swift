//
//  Offer.swift
//  FreeCorner
//
//  Created by Simon Dahan on 08/12/2021.
//

import Foundation
import Firebase
class Offer {
    let ref: DatabaseReference?
    let key: String
    let name: String
    let desctiption: String
    var images: [String]
    var owner: String
    var category: String
    
    // MARK: Initialize with Raw Data
    init(name: String, description: String, images: [String], owner: String, category: String, key: String) {
        self.ref = nil
        self.name = name
        self.desctiption = description
        self.images = images
        self.owner = owner
        self.category = category
        self.key = key
    }

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
    static func filterItemsByCategory(category: String, offers: [String: Offer]) -> [String: Offer] {
        var filteredOffers: [String: Offer] = [:]
        for offer in offers.values where offer.category == category {
            filteredOffers[offer.key] = offer
        }
        return filteredOffers
    }
}

extension Offer: Equatable {
    static func == (lhs: Offer, rhs: Offer) -> Bool {
        if lhs.desctiption == rhs.desctiption, lhs.images == rhs.images, lhs.key == rhs.key,
           lhs.name == rhs.name, lhs.owner == rhs.owner, lhs.category == rhs.category {
            return true
        }
        return false
    }
}

enum Categories: String, CaseIterable {
    case all = "All"
    case smartphone = "Smartphone"
    case furniture = "Furniture"
    case other = "Other"
}
