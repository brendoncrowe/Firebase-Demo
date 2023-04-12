//
//  DataBaseService.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/11/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class DataBaseService {
    
    static let itemsCollection = "items" // collection name
    
    // need a reference to the database that is being worked with
    private let dataBase = Firestore.firestore()
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document id/reference for the "items" collection for easier deletion later
        let documentReference = dataBase.collection(DataBaseService.itemsCollection).document()

        // create a document in "items" collection
        dataBase.collection(DataBaseService.itemsCollection).document(documentReference.documentID).setData(["itemName": itemName, "price": price, "itemId": documentReference.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
