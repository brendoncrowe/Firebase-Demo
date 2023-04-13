//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhotosUI

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    private var imagePickerController = UIImagePickerController()
    
    private var selectedImage: UIImage? {
        didSet {
            itemImageView.image = selectedImage
        }
    }
    
    private var category: Category
    private let dbService = DataBaseService()
    private lazy var gestureRecognizer: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer()
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
