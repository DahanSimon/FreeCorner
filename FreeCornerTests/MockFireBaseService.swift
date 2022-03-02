//
//  MockFireBaseService.swift
//  FreeCornerTests
//
//  Created by Simon Dahan on 31/12/2021.
//

import Foundation
@testable import FreeCorner

class MockFireBaseService: FireBaseServiceProtocol {
    func populateOffer(id: String, name: String, description: String, images: [String], owner: String, category: String) {
        <#code#>
    }
    
    func populateUser(id: String, name: String, phone: String, address: [String : String], offer: [String : String]?, email: String) {
        <#code#>
    }
    
    func deleteImage(offersId: String, imageId: String) {
        <#code#>
    }
    
    
    var offers: [String: Offer] = [:]
    var users: [String: User] = [:]
    var expectedOffersResult: [String: Offer] = [:]
    var expectedUsersResult: [String: User] = [:]
    private init() {}
    init(expectedOffers: [String: Offer], expectedUsers: [String: User]) {
        self.expectedOffersResult = expectedOffers
        self.expectedUsersResult = expectedUsers
    }
    
    func getOffers(callback: @escaping ([String: Offer], Bool) -> Void) {
        self.offers = expectedOffersResult
        callback(offers, true)
    }
    
    func getUsers(callback: @escaping ([String: User], Bool) -> Void) {
        self.users = expectedUsersResult
        callback(users, true)
    }
    
}
