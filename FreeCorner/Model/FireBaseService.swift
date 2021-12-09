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
    
    func populateOffer(name: String, description: String, images: [String],owner: String, category: String, callback: @escaping (Bool) -> Void) {
        for i in 1...20 {
            ref.getData { dataError, data in
                self.ref.child("offers/\(i)/name").setValue(name)
                self.ref.child("offers/\(i)/description").setValue(description)
                self.ref.child("offers/\(i)/images").setValue(images)
                self.ref.child("offers/\(i)/owner").setValue(owner)
                self.ref.child("offers/\(i)/category").setValue(category)
            }
        }
        callback(true)
    }
    
    func populateUser(name: String, phone: String, address: String, offer: [String], email: String) {
        for i in 1...20 {
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
