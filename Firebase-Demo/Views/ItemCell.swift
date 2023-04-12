//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/12/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    

    public func configureCell(for item: Item) {
        itemNameLabel.text = item.itemName
        sellerNameLabel.text = "@" + item.sellerName
        dateLabel.text = item.listedDate.description
        priceLabel.text = "$" + String(format: "%.2f", item.price)
    }
}
