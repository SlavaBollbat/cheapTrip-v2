//
//  LoginViewController.swift
//  CheapTrip
//
//  Created by Слава on 19.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        warningLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener {(auth, user) in

            if user != nil {
                
                UserService.observeUser(user!.uid, completion: { (user) in
                    UserService.currentUser = user
                    self.performSegue(withIdentifier: "showMainVC", sender: nil)
                })
                
            } else {
                
                UserService.currentUser = nil
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func unwindToLogInVC(segue: UIStoryboardSegue) {
        do {
            try Auth.auth().signOut()
            
        } catch let error {
            print("Error trying to sign out of Firebase: \(error.localizedDescription)")
        }
        
    }
    
    func displayWarning(text: String) {
        warningLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.warningLabel.alpha = 1
        }) { (success) in
            if success {
                self.warningLabel.alpha = 0
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text,
            email != "", password != "" else {
                displayWarning(text: "Info is incorrect")
                return
        }
        
        
        Auth.auth().signIn(withEmail: email, password: password) { auth, error in
            if error != nil {
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
        
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "ShowAccountVC", sender: nil)
        
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
}

