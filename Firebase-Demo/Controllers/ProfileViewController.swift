//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhotosUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.delegate = self
        updateUI()
    }
    
    private func updateUI() { // set the user info with this function
        guard let user = Auth.auth().currentUser else {
            return
        }
        emailLabel.text = user.email
        displayNameTextField.text = user.displayName
        //        user.displayName
        //        user.photoURL
        //        user.phoneNumber
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        // change the user's display name
        
        guard let displayName = displayNameTextField.text, !displayName.isEmpty else {
            print("missing fields")
            return
        }
        // to make a change to the user's name, you must make a request to Firebase
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = displayName
        request?.commitChanges(completion: { [unowned self] error in
            if let error = error {
                self.showAlert(title: "Profile Update", message: "Error changing profile: \(error)")
            } else {
                self.showAlert(title: "Profile Update", message: "Successfully updated profile")
            }
        })
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyBoardName: "LoginView", viewControllerID: "LoginViewController")
        } catch {
            print("error signing out: \(error)")
        }
    }
    
    
    
    @IBAction func editProfileImagePressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: nil)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.changeProfileImage()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
        
    }
    
   private func changeProfileImage() {
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

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if !results.isEmpty {
            let result = results.first!
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        self?.showAlert(title: "Image Error", message: "Could not set image")
                        return
                    }
                    guard let image = image as? UIImage else {
                        print("could not typecast image data")
                        return
                    }
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
