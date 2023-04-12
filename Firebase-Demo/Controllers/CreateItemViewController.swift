//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    private var category: Category
    private let dbService = DataBaseService()
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name

    }
    
    @IBAction func listButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: create item and push to firebase 
        guard let itemName = itemTitleTextField.text, !itemName.isEmpty, let priceText = itemPriceTextField.text, !priceText.isEmpty, let price = Double(priceText)  else { showAlert(title: "Missing Fields", message: "All fields are required")
            return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please set display name in profile page.")
            return
        }
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "There was an error listing your item...\(error.localizedDescription)")
                }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "Yay!", message: "Your item has been successfully listed 🥳")
                }
            }
        }
    }
}
