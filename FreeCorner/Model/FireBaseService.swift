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
    static let userRef = Database.database().reference(withPath: "users")
    static var refObservers: [DatabaseHandle] = []
    static var offers:[Offer] = []
    static var users:[String: User] = [:]
    static func getOffers() {
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
    }
    static func getUsers() {
        userRef.observe(.value, with: { snapshot in
            let completed = userRef.observe(.value) { snapshot in
                var newItems: [String: User] = [:]
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let user = User(snapshot: snapshot) {
                        newItems[user.key] = user
                    }
                }
                FireBaseService.users = newItems
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
