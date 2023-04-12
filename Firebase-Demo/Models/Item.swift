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
    let itemID: String // firebase document id
    let listedDate: Date
    let sellerName: String
    let sellerId: String
    let categoryName: String
}
