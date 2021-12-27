//
//  FireBaseService.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class FireBaseService {
    let ref = Database.database().reference()
    static let offersRef = Database.database().reference(withPath: "offers")
    let userRef = Database.database().reference(withPath: "users")
    static var refObservers: [DatabaseHandle] = []
    static var offers:[Offer] = []
    static func getOffers() -> [Offer] {
        var offersList: [Offer] = []
        offersRef.observe(.value, with: { snapshot in
            let completed = self.offersRef.observe(.value) { snapshot in
                var newItems: [Offer] = []
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let offer = Offer(snapshot: snapshot) {
                        newItems.append(offer)
                    }
                }
                FireBaseService.offers = newItems
            }
            self.refObservers.append(completed)
        })
        return offersList
    }
    func populateOffer(id:Int, name: String, description: String, images: [String],owner: String, category: String) {
            self.ref.child("offers/\(id)/name").setValue(name)
            self.ref.child("offers/\(id)/description").setValue(description)
            self.ref.child("offers/\(id)/images").setValue(images)
            self.ref.child("offers/\(id)/owner").setValue(owner)
            self.ref.child("offers/\(id)/category").setValue(category)
    }
    
    func populateUser(id: String,name: String, phone: String, address: [String: String], offer: [String]?, email: String) {
            ref.getData { dataError, data in
                self.ref.child("users/\(id)/name").setValue(name)
                self.ref.child("users/\(id)/phone").setValue(phone)
                self.ref.child("users/\(id)/address").setValue(address)
                self.ref.child("users/\(id)/offer").setValue(offer)
                self.ref.child("users/\(id)/email").setValue(email)
            }
    }
    func deleteImage(offersId: String, imageId: String) {
        FireBaseService.offersRef.child(offersId).child("images").child(imageId).removeValue()
    }
}
