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
    static let usersCollection = "users"
    static let commentsCollection = "comments" // sub collection on an item document
    
    // need a reference to the database that is being worked with
    private let dataBase = Firestore.firestore()
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document id/reference for the "items" collection for easier deletion later
        let documentReference = dataBase.collection(DataBaseService.itemsCollection).document()
        
        // create a document in "items" collection
        dataBase.collection(DataBaseService.itemsCollection).document(documentReference.documentID).setData(["itemName": itemName, "price": price, "itemId": documentReference.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(documentReference.documentID))
            }
        }
    }
    
    public func createDataBaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let email = authDataResult.user.email else { return }
        dataBase.collection(DataBaseService.usersCollection).document(authDataResult.user.uid).setData(["email": email, "createdDate": Timestamp(date: Date()), "userId": authDataResult.user.uid]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func updateDataBaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) ->()) {
        guard let user = Auth.auth().currentUser else { return }
        dataBase.collection(DataBaseService.usersCollection).document(user.uid).updateData(["photoURL" : photoURL, "displayName" : displayName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func delete(item: Item, completion: @escaping (Result<Bool, Error>) ->()) {
        dataBase.collection(DataBaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
