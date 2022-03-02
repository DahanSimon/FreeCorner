//
//  FireBaseServiceProtocol.swift
//  FreeCorner
//
//  Created by Simon Dahan on 31/12/2021.
//

import Foundation

protocol FireBaseServiceProtocol {
    var offers: [String: Offer] { get }
    var users: [String: User] { get }
    func getOffers(callback: @escaping ([String: Offer], Bool) -> Void)
    func getUsers(callback: @escaping ([String: User], Bool) -> Void)
    func populateOffer(id: String, name: String, description: String, images: [String], owner: String, category: String)
    func populateUser(id: String, name: String, phone: String, address: [String: String], offer: [String: String]?, email: String)
    func deleteImage(offersId: String, imageId: String)
}
