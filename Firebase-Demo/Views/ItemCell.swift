//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/12/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    public func configureCell(for item: Item) {
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate.dateValue(), price: item.price)
    }
    
    public func configureCell(for favorite: Favorite) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: "missing name", date: favorite.favoritedDate.dateValue(), price: favorite.price)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Date, price: Double ) {
        itemImageView.kf.setImage(with: URL(string: imageURL))
        itemNameLabel.text = itemName
        sellerNameLabel.text = "@" + sellerName
        dateLabel.text = date.description
        let price = String(format: "%.2f", price)
        priceLabel.text = "$" + price
    }
    
}
