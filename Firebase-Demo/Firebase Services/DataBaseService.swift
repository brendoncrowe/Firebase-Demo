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
    
   static let shared = DataBaseService()
    
    private init() {}
    
    static let itemsCollection = "items" // collection name
    static let usersCollection = "users"
    static let commentsCollection = "comments" // sub collection on an item document
    static let favoritesCollection = "favorites"
    
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
    
    public func postComment(item: Item, comment: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser, let displayName = user.displayName else {
            print("Missing user data")
            return
        }
        let docRef = dataBase // create a new document reference
            .collection(DataBaseService.itemsCollection)
            .document(item.itemId)
            .collection(DataBaseService
                .commentsCollection).document()
        
        // using the above document, the below code writes to it
        dataBase.collection(DataBaseService.itemsCollection)
            .document(item.itemId)
            .collection(DataBaseService.commentsCollection)
            .document(docRef.documentID)
            .setData(["text" : comment, "commentDate": Timestamp(date: Date()), "itemName": item.itemName, "itemId": item.itemId, "sellerName": item.sellerName, "commentedBy": displayName, "sellerId": item.sellerId]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    public func addToFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        dataBase.collection(DataBaseService.usersCollection).document(user.uid).collection(DataBaseService.favoritesCollection).document(item.itemId).setData(["itemName" : item.itemName, "price": item.price, "imageURL": item.imageURL, "favoritedDate": Timestamp(date: Date()), "itemId": item.itemId, "sellerId": item.sellerId, "sellerName": item.sellerName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        dataBase.collection(DataBaseService.usersCollection).document(user.uid).collection(DataBaseService.favoritesCollection).document(item.itemId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func checkItemIsInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        // in firebase use the "where" keyword to query/search a collection
        dataBase.collection(DataBaseService.usersCollection).document(user.uid).collection(DataBaseService.favoritesCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments { snapshot, error in
            // getDocuments - fetches documents only once
            // addSnapShotListener - continues to listen for modifications to a collection
            
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let count = snapshot.documents.count // check if there are documents 
                if count > 0 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        dataBase.collection(DataBaseService.itemsCollection).whereField("sellerId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map { Item($0.data()) }
                completion(.success(items.sorted { $0.listedDate.dateValue() > $1.listedDate.dateValue()}))
            }
        }
    }
    
    public func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        dataBase.collection(DataBaseService.usersCollection).document(user.uid).collection(DataBaseService.favoritesCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let favorites = snapshot.documents.map { Favorite($0.data()) }
                completion(.success(favorites.sorted { $0.favoritedDate.dateValue() > $1.favoritedDate.dateValue()}))
            }
        }
    }
}
