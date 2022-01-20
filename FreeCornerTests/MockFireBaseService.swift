//
//  MockFireBaseService.swift
//  FreeCornerTests
//
//  Created by Simon Dahan on 31/12/2021.
//

import Foundation
@testable import FreeCorner

class MockFireBaseService: FireBaseServiceProtocol {
    
    var offers: [String: Offer] = [:]
    var users: [String: User] = [:]
    var expectedOffersResult: [String: Offer] = [:]
    var expectedUsersResult: [String: User] = [:]
//    static var shared = MockFireBaseService()
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
