//
//  User.swift
//  CheapTrip
//
//  Created by Слава on 30.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import Foundation

class User {
    
    var uid: String
    var username: String
    var phonenumber: String
    var photoURL: URL
    
    init(uid: String, username: String, phoneNumber: String, photoURL: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
        self.phonenumber = phoneNumber
    }
}
