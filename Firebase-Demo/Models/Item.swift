//
//  Item.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/11/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import Foundation

struct Item {
    let itemName: String
    let price: Double
    let itemId: String // firebase document id
    let listedDate: Date
    let sellerName: String
    let sellerId: String
    let categoryName: String
}

extension Item {
    init(_ dictionary: [String: Any]) {
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.price = dictionary["price"] as? Double ?? 0.0
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.listedDate = dictionary["listedDate"] as? Date ?? Date()
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
        self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
        self.categoryName = dictionary["categoryName"] as? String ?? "no category name"
    }
}
