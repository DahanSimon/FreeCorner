//
//  FireBaseService.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class FireBaseService: FireBaseServiceProtocol {
    static let shared = FireBaseService()
    let ref = Database.database().reference()
    private let offersRef = Database.database().reference(withPath: "offers")
    private let userRef = Database.database().reference(withPath: "users")
    static var refObservers: [DatabaseHandle] = []
    var offers: [String: Offer] = [:]
    var users: [String: User] = [:]
    private init() {}
    let connectedRef = Database.database().reference(withPath: ".info/connected")
    var isConnceted: Bool = false
    func testConnection(callback: @escaping (Bool) -> Void) {
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.isConnceted = true
                callback(true)
            } else {
                self.isConnceted = false
                callback(false)
            }
        })
    }
    // This method updates the offers dictionnary by observing chnages on firebase realtime database
    func getOffers(callback: @escaping ([String: Offer], Bool) -> Void) {
        offersRef.observe(.value, with: { snapshot in
            var newItems: [String: Offer] = [:]
            for child in snapshot.children {
                if
                    let snapshot1 = child as? DataSnapshot,
                    let offer = Offer(snapshot: snapshot1) {
                    newItems[offer.key] = offer
                }
            }
            self.offers = newItems
            callback(newItems, true)
        })
    }
    
    // This method updates the users dictionnary by observing chnages on firebase realtime database
    func getUsers(callback: @escaping ([String: User], Bool) -> Void) {
        userRef.observe(.value, with: { snapshot in
            var newItems: [String: User] = [:]
            for child in snapshot.children {
                if
                    let snapshot = child as? DataSnapshot,
                    let user = User(snapshot: snapshot) {
                    newItems[user.key] = user
                }
            }
            self.users = newItems
            callback(newItems, true)
        })
    }
    
    func populateOffer(id: String, name: String, description: String, images: [String], owner: String, category: String) {
        self.ref.child("offers/\(id)/name").setValue(name)
        self.ref.child("offers/\(id)/description").setValue(description)
        self.ref.child("offers/\(id)/images").setValue(images)
        self.ref.child("offers/\(id)/owner").setValue(owner)
        self.ref.child("offers/\(id)/category").setValue(category)
    }
    
    func populateUser(id: String, name: String, phone: String, address: [String: String], offer: [String: String]?, email: String) {
        self.ref.child("users/\(id)/name").setValue(name)
        self.ref.child("users/\(id)/phone").setValue(phone)
        self.ref.child("users/\(id)/address").setValue(address)
        self.ref.child("users/\(id)/offers").setValue(offer)
        self.ref.child("users/\(id)/email").setValue(email)
    }
    
    // This method delete images from the firebase realtime Database
    func deleteImage(offersId: String, imageId: String) {
        offersRef.child(offersId).child("images").child(imageId).removeValue()
    }
}
