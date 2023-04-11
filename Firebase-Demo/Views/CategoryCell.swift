//
//  CategoryCell.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/11/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    
    public func configureCellUI(for category: Category) {
        categoryImageView.image = category.image
        categoryNameLabel.text = category.name
    }
}
