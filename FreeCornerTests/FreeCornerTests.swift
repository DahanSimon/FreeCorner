//
//  FreeCornerTests.swift
//  FreeCornerTests
//
//  Created by Simon Dahan on 07/12/2021.
//

import XCTest
import FirebaseDatabase
@testable import FreeCorner

class FreeCornerTests: XCTestCase {

    func testCreateOffer() {
        
        let user = User(name: "test", phone: "test", offer: [:], address: [:], email: "test@mail.com", key: "1")
        let offer = Offer(name: "Create Offer Test", description: "Create Offer Test", images: ["example.com"], owner: user.name, category: "Smartphone", key: "1")
        var expectedOffer: [String: Offer] = [:]
        var expectedUser: [String: User] = [:]
        var responseOffer: [String: Offer] = [:]
        var responseUser: [String: User] = [:]
        expectedOffer[offer.key] = offer
        expectedUser[user.key] = user
        let mock = MockFireBaseService(expectedOffers: expectedOffer, expectedUsers: expectedUser)
        mock.getOffers { offers, _ in
            responseOffer = offers
        }
        mock.getUsers { users, _ in
            responseUser = users
        }
        XCTAssertEqual(expectedOffer, responseOffer)
        XCTAssertEqual(expectedUser, responseUser)
    }
    func testFilterOffersByCategory() {
        let user = User(name: "test", phone: "test", offer: [:], address: [:], email: "test@mail.com")
        let offer = Offer(name: "Create Offer Test", description: "Create Offer Test", images: ["example.com"], owner: user.name, category: "Smartphone", key: "1")
        let offer2 = Offer(name: "Create Offer Test", description: "Create Offer Test", images: ["example.com"], owner: user.name, category: "Furniture", key: "2")
        var expectedOffer: [String: Offer] = [:]
        var expectedUser: [String: User] = [:]
        var responseOffer: [String: Offer] = [:]
        var responseUser: [String: User] = [:]
        expectedOffer[offer.key] = offer
        expectedOffer[offer2.key] = offer2
        expectedUser[user.key] = user
        let mock = MockFireBaseService(expectedOffers: expectedOffer, expectedUsers: expectedUser)
        mock.getOffers { offers, _ in
            responseOffer = offers
        }
        mock.getUsers { users, _ in
            responseUser = users
        }
        let filteredOffer = Offer.filterItemsByCategory(category: "Smartphone", offers: responseOffer)
        XCTAssertEqual(expectedOffer, responseOffer)
        XCTAssertEqual(expectedUser, responseUser)
        XCTAssertEqual(filteredOffer.count, 1)
        XCTAssertEqual(filteredOffer.first?.value.category, "Smartphone")
    }
    
    func testUserEquatableProtocol() {
        let user1 = User(name: "John Doe", phone: "0123456789", offer: [:], address: [:], email: "test@mail.com")
        let user2 = user1
        
        XCTAssertTrue(user1 == user2)
        
        let user3 = User(name: "Jane Doe", phone: "0123456789", offer: [:], address: [:], email: "test@mail.com")
        XCTAssertFalse(user1 == user3)
    }
    
    func testOfferEquatableProtocol() {
        let offer1 = Offer(name: "offer", description: "test", images: [], owner: "user", category: "cat", key: "a")
        let offer2 = offer1
        
        XCTAssertTrue(offer1 == offer2)
        
        let offer3 = Offer(name: "Different Offer", description: "test", images: [], owner: "user", category: "cat", key: "a")
        XCTAssertFalse(offer1 == offer3)
    }
}
