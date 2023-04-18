//
//  Favorite.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/18/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import Foundation
import Firebase

struct Favorite {
    let itemName: String
    let itemId: String
    let price: Double
    let imageURL: String
    let favoritedDate: Timestamp
    let sellerId: String
    let sellerName: String
}

extension Favorite {
    init(_ dictionary: [String: Any]) {
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.price = dictionary["price"] as? Double ?? 0
        self.imageURL = dictionary["imageURL"] as? String ?? "no image url"
        self.favoritedDate = dictionary["favoritedDate"] as? Timestamp ?? Timestamp(date: Date())
        self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
    }
}
