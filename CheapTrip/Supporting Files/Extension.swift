//
//  File.swift
//  CheapTrip
//
//  Created by Слава on 26.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import Foundation

extension String {
    
    static func random() -> String {
        
        let length = 20
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
