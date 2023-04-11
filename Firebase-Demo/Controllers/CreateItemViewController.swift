//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit

class CreateItemViewController: UIViewController {
    
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    private var category: Category
    
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
        
    }
}
