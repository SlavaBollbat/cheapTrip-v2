//
//  AccountViewController.swift
//  CheapTrip
//
//  Created by Слава on 29.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class AccountViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tapToChangeImageButton: UIButton!
    
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTap)
        
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        userImageView.layer.masksToBounds = true
        tapToChangeImageButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
    }
    
    
    @objc func openImagePicker() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    @objc func textFieldChanged(_ target:UITextField) {
        
        let name = nameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        let phoneNumber = phoneNumberTextField.text
        
        let isFilled = (name != "") && (email != "") && (password != "") && (phoneNumber != "")
        
        setCreateButton(enabled: isFilled)
    }
    
    func setCreateButton(enabled: Bool) {
        if enabled {
            createButton.alpha = 1.0
            createButton.isEnabled = true
        } else {
            createButton.alpha = 0.5
            createButton.isEnabled = false
        }
    }
    
    @IBAction func CancelPressed(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let image = userImageView.image else { return }
        guard let phoneNumber = phoneNumberTextField.text else { return }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error == nil && authResult?.user != nil {
                
                self.uploadProfileImage(image, completion: { (url) in
                    
                    self.saveProfile(username: name, phoneNumber: phoneNumber, imageURL: url!, completion: { (success) in
                        if success {
                            self.performSegue(withIdentifier: "showMain", sender: self)
                        }
                    })
                    
                })
            }
            
        }

        
    }
    
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping (_ url: URL?)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func saveProfile(username:String, phoneNumber: String, imageURL:URL, completion: @escaping ((_ success: Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        
        let value = [
            "username": username,
            "phoneNumber": phoneNumber,
            "photoURL": imageURL.absoluteString
            ] as [String: Any]
        
        databaseRef.setValue(value) { error, ref in
            completion(error == nil)
        }
    }
}

extension AccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
        return true
    }
}

extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = pickedImage
        }
        
        
        picker.dismiss(animated: true, completion: nil )
    }
}


