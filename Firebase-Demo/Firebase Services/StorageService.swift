//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/12/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseStorage

// *** References are SUPER important in firebase ***

class StorageService {
    
    // in the app photos will be uploaded to storage in two places...
    // 1. ProfileViewController
    // 2. CreateItemViewController
    
    // There will be two different buckets of folders; 1. UserProfilePhoto/userId & 2. ItemPhoto/itemId
    
    // create a reference to the firebase storage
    private let storageReference = Storage.storage().reference()
    
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        // 1. convert UIImage to Data because that is what is being sent to firebase storage
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        // 2. establish which collection/bucket that the photo will be saved to
        var photoReference: StorageReference!
        if let userId = userId { // coming from ProfileViewController
            photoReference = storageReference.child("UserProfilePhotos/\(userId).jpg") // similar to .append(); creates a sub folder
        } else if let itemId = itemId { // coming from ItemViewController
            photoReference = storageReference.child("ItemPhotos/\(itemId).jpg")
        }
        
        // 3. configure metadata for the object being uploaded
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg" // telling firebase the mime type/content
        
        // 4. get the download url for the image
        let _ = photoReference.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                photoReference.downloadURL { url, error in // the image url that can be passed around 
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
        }
    }
}
