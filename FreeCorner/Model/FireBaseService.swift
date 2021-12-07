//
//  FireBaseService.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import Foundation
import FirebaseDatabase

class FireBaseService {
    
    func populateOffer(name: String, description: String, images: [String],owner: String, category: String) {
        let ref = Database.database().reference()
        for i in 1...20 {
            ref.getData { dataError, data in
                ref.child("offers/\(i)/name").setValue(name)
                ref.child("offers/\(i)/descrition").setValue(description)
                ref.child("offers/\(i)/images").setValue(images)
                ref.child("offers/\(i)/owner").setValue(owner)
                ref.child("offers/\(i)/category").setValue(category)
            }
        }
        
    }
    
    func populateUser(name: String, phone: String, address: String, offer: [String], email: String) {
        let ref = Database.database().reference()
        for i in 1...20 {
            ref.getData { dataError, data in
                ref.child("users/\(i)/name").setValue(name)
                ref.child("users/\(i)/phone").setValue(phone)
                ref.child("users/\(i)/address").setValue(address)
                ref.child("users/\(i)/offer").setValue(offer)
                ref.child("users/\(i)/email").setValue(email)
            }
        }
    }
}
