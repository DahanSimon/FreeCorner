//
//  StorageService.swift
//  FreeCorner
//
//  Created by Simon Dahan on 14/03/2022.
//

import Foundation
import Firebase
class StorageService {
    private let offersRef = Database.database().reference(withPath: "offers")
    private let storage   = Storage.storage().reference()

    func saveImage(imageData: Data, offerId: String, index: Int, callback: @escaping (Bool, URL?) -> Void) {
        storage.child("images/\(offerId)/image\(index).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                callback(false, nil)
                return
            }
            self.storage.child("images/\(offerId)/image\(index).png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    callback(false, nil)
                    return
                }
                callback(true, url)
            }
        }
    }
    func deleteImages(offerId: String) {
        storage.child("images/\(offerId)").delete { _ in }
    }
}
