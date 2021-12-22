//
//  FireBaseService.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import Foundation
import FirebaseDatabase

class FireBaseService {
    let ref = Database.database().reference()
    let offersRef = Database.database().reference(withPath: "offers")
    var refObservers: [DatabaseHandle] = []
    var offers:[Offer] = []
    func getOffers() {
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
                self.offers = newItems
            }
            self.refObservers.append(completed)
        })
    }
    func populateOffer(id:Int, name: String, description: String, images: [String],owner: String, category: String) {
            self.ref.child("offers/\(id)/name").setValue(name)
            self.ref.child("offers/\(id)/description").setValue(description)
            self.ref.child("offers/\(id)/images").setValue(images)
            self.ref.child("offers/\(id)/owner").setValue(owner)
            self.ref.child("offers/\(id)/category").setValue(category)
    }
    
    func populateUser(name: String, phone: String, address: [String: String], offer: [String], email: String) {
        for i in 1...2 {
            ref.getData { dataError, data in
                self.ref.child("users/\(i)/name").setValue(name)
                self.ref.child("users/\(i)/phone").setValue(phone)
                self.ref.child("users/\(i)/address").setValue(address)
                self.ref.child("users/\(i)/offer").setValue(offer)
                self.ref.child("users/\(i)/email").setValue(email)
            }
        }
    }
}
