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
}
