//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/16/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemDetailController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var containerViewYConstraint: NSLayoutConstraint!
    
    private var item: Item
    private var originalValueForConstraint: CGFloat = 0
    private var dataBase = DataBaseService()
    private var listener: ListenerRegistration?
    private var isFavorited = false {
        didSet {
            if isFavorited {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            }
        }
    }
    
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        return formatter
    }()
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = item.itemName
        configureVC()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardNotifications()
        
        listener = Firestore.firestore().collection(DataBaseService.itemsCollection).document(item.itemId).collection(DataBaseService.commentsCollection).addSnapshotListener({ [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try Again", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                let comments = snapshot.documents.map { Comment($0.data()) }
                self?.comments = comments.sorted { $0.commentDate.dateValue() > $1.commentDate.dateValue() }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        listener?.remove()
    }
    
    private func updateUI() {
        // check if item is favorited in order to update heart button
        dataBase.checkItemIsInFavorites(item: item) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again", message: error.localizedDescription)
                }
            case .success(let success):
                if success {
                    self?.isFavorited = true
                } else {
                    self?.isFavorited = false
                }
            }
        }
    }
    
    private func configureVC() {
        tableView.dataSource = self
        commentTextField.delegate = self
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        originalValueForConstraint = containerViewYConstraint.constant
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func postCommentButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        // comment to post to firebase
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            showAlert(title: "Missing fields", message: "Please enter a comment")
            return
        }
        postComment(text: commentText)
    }
    
    private func postComment(text: String) {
        dataBase.postComment(item: item, comment: text) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Comment error", message: "Error posting comment: \(error.localizedDescription)")
                    self?.commentTextField.text?.removeAll()
                }
            case .success:
                DispatchQueue.main.async {
                    self?.commentTextField.text?.removeAll()
                }
            }
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        //        print(notification.userInfo ?? "") get the key that contains the keyboard frame
        guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else { return }
        // adjust the containerViewYConstraint
        containerViewYConstraint.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        dismissKeyboard()
    }
    
    @objc private func dismissKeyboard() {
        containerViewYConstraint.constant = originalValueForConstraint
        commentTextField.resignFirstResponder()
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        
        if isFavorited { // remove from favorites
            dataBase.removeFromFavorites(item: item) { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Favoriting Error", message: error.localizedDescription)
                    }
                case .success:
                    DispatchQueue.main.async {
                        print("item was removed")
                        self?.isFavorited = false
                    }
                }
            }
        } else { // add to favorites
            dataBase.addToFavorites(item: item) { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Favoriting Error", message: error.localizedDescription)
                    }
                case .success:
                    DispatchQueue.main.async {
                        print("item was favorited")
                        self?.isFavorited = true
                    }
                }
            }
        }
    }
}

extension ItemDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = comments[indexPath.row]
        let dateString = dateFormatter.string(from: comment.commentDate.dateValue())
        var content = cell.defaultContentConfiguration()
        content.text = comment.text
        content.secondaryText = "@" + comment.sellerName + " \(dateString)"
        cell.contentConfiguration = content
        return cell
    }
}


extension ItemDetailController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

