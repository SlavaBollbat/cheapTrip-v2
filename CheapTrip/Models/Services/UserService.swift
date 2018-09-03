//
//  UserService.swift
//  CheapTrip
//
//  Created by Слава on 30.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    static var currentUser: User?
    
    static func observeUser(_ uid: String, completion: @escaping (_ user: User?)->()) {

        let userRef = Database.database().reference().child("users/\(uid)")

        userRef.observe(.value) { (snapshot) in
            var user: User?

            if let dict = snapshot.value as? [String: Any],
                let phoneNumber = dict["phoneNumber"] as? String,
                let photoURL = dict["photoURL"] as? String,
                let username = dict["username"] as? String,
                let url = URL(string: photoURL) {

                user = User(uid: snapshot.key, username: username, phoneNumber: phoneNumber, photoURL: url)

            }
                completion(user)
        }
    }

    
    
    
}
