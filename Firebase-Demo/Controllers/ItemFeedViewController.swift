//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var listener: ListenerRegistration?
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DataBaseService.itemsCollection).addSnapshotListener({ [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again later", message: "\(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map { Item($0.data()) }
                self?.items = items
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove() // no longer listening for changes from firebase
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ItemFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.itemName
        let price = "$" + String(format: "%.2f", item.price)
        content.secondaryText = price
        cell.contentConfiguration = content
        return cell
    }
}


extension ItemFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

