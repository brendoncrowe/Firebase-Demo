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
    
    
    public func configureCell(for category: Category) {
      let colorImage = category.image.withTintColor(UIColor.generateRandomColor(), renderingMode: .alwaysOriginal)
      categoryImageView.image = colorImage
      categoryNameLabel.text = category.name
    }
  }

  extension UIColor {
    static func generateRandomColor() -> UIColor {
        let redValue = CGFloat.random(in: 0...1)
        let greenValue = CGFloat.random(in: 0...1)
        let blueValue = CGFloat.random(in: 0...1)
        let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        return randomColor
    }
  }
