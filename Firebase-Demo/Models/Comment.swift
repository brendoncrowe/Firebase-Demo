//
//  Comment.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/17/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let commentDate: Timestamp
    let commentedBy: String
    let itemId: String
    let itemName: String
    let sellerId: String
    let sellerName: String
    let text: String
}

extension Comment {
    init(_ dictionary: [String: Any]) {
        self.commentDate = dictionary["commentDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commentedBy = dictionary["commentedBy"] as? String ?? "no commentedBy name"
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
        self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
        self.text = dictionary["text"] as? String ?? "no comment text"
    }
}
