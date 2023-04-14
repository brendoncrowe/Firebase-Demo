//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private let storageService = StorageService()
    
    private var selectedImage: UIImage? {
        didSet {
            itemImageView.image = selectedImage
        }
    }
    
    private var category: Category
    private let dbService = DataBaseService()
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 1
        gr.delegate = self
        return gr
    }()
    
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
        setupGesture()
    }
    
    private func setupGesture() {
        itemImageView.isUserInteractionEnabled = true
        gestureRecognizer.addTarget(self, action: #selector(addItemImage))
        itemImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func listButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: create item and push to firebase
        guard let itemName = itemTitleTextField.text, !itemName.isEmpty, let priceText = itemPriceTextField.text, !priceText.isEmpty, let price = Double(priceText), let selectedImage = selectedImage else { showAlert(title: "Missing Fields", message: "All fields are required along with a photo")
            return
        }
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please set display name in profile page.")
            return
        }
        // resize image before uploading to storage
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "There was an error listing your item...\(error.localizedDescription)")
                }
            case .success( let documentId):
                self?.uploadPhoto(photo: resizedImage, documentId: documentId)
            }
        }
    }
    
    private func uploadPhoto(photo: UIImage, documentId: String) {
        storageService.uploadPhoto(itemId: documentId, image: photo) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updateItemImageURL(_ url: URL, documentId: String) {
        // update an existing document on Firebase
        Firestore.firestore().collection(DataBaseService.itemsCollection).document(documentId).updateData(["imageURL": url.absoluteString]) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Failed to update item", message: "\(error.localizedDescription)")
                }
            } else {
                print("image was updated")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func addItemImage() {
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.configurePHPicker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func configurePHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let phpController = PHPickerViewController(configuration: configuration)
        if let sheet = phpController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        phpController.delegate = self
        present(phpController, animated: true)
    }
}

extension CreateItemViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if !results.isEmpty {
            let result = results.first!
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        self?.showAlert(title: "Image Error", message: "Could not set image: \(error)")
                        return
                    }
                    guard let image = image as? UIImage else {
                        print("could not typecast image data")
                        return
                    }
                    DispatchQueue.main.async {
                        self?.selectedImage = image
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
}

extension CreateItemViewController: UIGestureRecognizerDelegate {
    
}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        selectedImage = image
        dismiss(animated: true)
    }
}
