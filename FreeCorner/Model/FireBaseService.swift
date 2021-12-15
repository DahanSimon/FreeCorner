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
        for i in 1...2 {
            ref.getData { dataError, data in
                self.ref.child("offers/\(i)/name").setValue(name)
                self.ref.child("offers/\(i)/description").setValue(description)
                self.ref.child("offers/\(i)/images").setValue(images)
                self.ref.child("offers/\(i)/owner").setValue(owner)
                self.ref.child("offers/\(i)/category").setValue(category)
            }
        }
        for i in 3...20 {
            self.ref.child("offers/\(i)/name").setValue("phone")
            self.ref.child("offers/\(i)/description").setValue("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries")
            self.ref.child("offers/\(i)/images").setValue(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXoePm8u-IAVSlg_r1H8XxiPa7nX_hMxYUFA&usqp=CAU"])
            self.ref.child("offers/\(i)/owner").setValue("2")
            self.ref.child("offers/\(i)/category").setValue("smartphone")
        }
        callback(true)
    }
    
    func populateUser(name: String, phone: String, address: [String: String], offer: [String], email: String) {
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
