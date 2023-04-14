//
//  ViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

enum AccountState {
    case existingUser
    case newUser
}

enum LoginMessages: String {
    case createAccount = ""
    case login = "Welcome back!"
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountStateMessageLabel: UILabel!
    @IBOutlet weak var accountStateButton: UIButton!
    
    private var accountState: AccountState = .existingUser
    private var authSession = AuthenticationSession()
    private var dataBase = DataBaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearErrorLabel()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text,
              !email.isEmpty,
              let password = passwordTextField.text,
              !password.isEmpty else {
            print("missing fields")
            return
        }
        continueLoginFlow(email: email, password: password)
    }
    
    private func continueLoginFlow(email: String, password: String) {
        if accountState == .existingUser {
            authSession.signInExistingUser(email: email, password: password) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.setUserLoginUI(color: .systemRed, text: "\(error.localizedDescription)")
                case .success:
                    DispatchQueue.main.async {
                        self?.navigateToMainView()
                    }
                }
            }
        } else {
            authSession.createNewUser(email: email, password: password) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    self?.setUserLoginUI(color: .systemRed, text: "\(error.localizedDescription)")
                case .success(let authDataResult):
                    // Create a database user only from a new authenticated account
                    self?.createDatabaseUser(authDataResult: authDataResult)
                }
            }
        }
    }
    
    private func createDatabaseUser(authDataResult: AuthDataResult) {
        dataBase.createDataBaseUser(authDataResult: authDataResult) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error creating user", message: error.localizedDescription)
                }
            case .success:
                DispatchQueue.main.async {
                    self?.navigateToMainView()
                }
            }
        }
    }
    
    private func setUserLoginUI(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = text
            self.errorLabel.textColor = color
        }
    }
    
    private func navigateToMainView() {
        UIViewController.showViewController(storyBoardName: "MainView", viewControllerID: "MainTabBarController")
    }
    
    private func clearErrorLabel() {
        errorLabel.text = ""
    }
    
    @IBAction func toggleAccountState(_ sender: UIButton) {
        // change the account login state
        accountState = accountState == .existingUser ? .newUser : .existingUser
        
        // animation duration
        let duration: TimeInterval = 0.3
        
        if accountState == .existingUser {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Login", for: .normal)
                self.accountStateMessageLabel.text = "Don't have an account?"
                self.accountStateButton.setTitle("SIGNUP", for: .normal)
            }, completion: nil)
        } else {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Sign Up", for: .normal)
                self.accountStateMessageLabel.text = "Already have an account?"
                self.accountStateButton.setTitle("LOGIN", for: .normal)
            }, completion: nil)
        }
    }
}
