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

protocol ItemCellDelegate: AnyObject {
    func didSelectSeller(_ itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var currentItem: Item!
    public weak var delegate: ItemCellDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap))
        return gesture
    }()
    
    override func layoutSubviews() { // called when the view loads its subviews
        super.layoutSubviews()
        configureTapGesture()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelectSeller(self, item: currentItem)
    }
    
    public func configureCell(for item: Item) {
        currentItem = item
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate.dateValue(), price: item.price)
    }
    
    public func configureCell(for favorite: Favorite) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.sellerName, date: favorite.favoritedDate.dateValue(), price: favorite.price)
    }
    
    fileprivate func configureTapGesture() {
        sellerNameLabel.textColor = .systemBlue
        sellerNameLabel.isUserInteractionEnabled = true
        sellerNameLabel.addGestureRecognizer(tapGesture)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Date, price: Double ) {
        itemImageView.kf.setImage(with: URL(string: imageURL))
        itemNameLabel.text = itemName
        sellerNameLabel.text = "@" + sellerName
        dateLabel.text = date.dateString()
        let price = String(format: "%.2f", price)
        priceLabel.text = "$" + price
    }
}
