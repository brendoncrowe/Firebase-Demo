//
//  SellerItemsController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/18/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class SellerItemsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var database = DataBaseService()
    private var item: Item
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        tableView.dataSource = self
        tableView.delegate = self
        fetchSellerItems()
        fetchSellerPhoto()
        title = "\(item.sellerName)'s Items"
    }
    
    private func fetchSellerItems() {
        database.fetchUserItems(userId: item.sellerId) { [weak self] result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error loading items", message: "The seller's items could not be loaded")
                }
            case .success(let items):
                    self?.items = items
            }
        }
    }
    
    private func fetchSellerPhoto() {
        Firestore.firestore().collection(DataBaseService.usersCollection).document(item.sellerId).getDocument { [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error loading user photo", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                if let photoURL = snapshot.data()?["photoURL"] as? String {
                    DispatchQueue.main.async {
                        self?.tableView.tableHeaderView = HeaderView(imageURL: photoURL)
                    }
                }
            }
        }
    }
}

extension SellerItemsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else { fatalError("could not load ItemCell") }
        let item = items[indexPath.row]
        cell.configureCell(for: item)
        return cell
    }
}

extension SellerItemsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
