//
//  Ride.swift
//  CheapTrip
//
//  Created by Слава on 30.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import Foundation
import MapKit

class Ride {
    
    var id: String
    var owner: User
    var date: String
    var sourceAddress: String
    var destinationAddress: String
    var firstLongitude: CLLocationDegrees
    var firstLatitude: CLLocationDegrees
    var secondLongitude: CLLocationDegrees
    var secondLatitude: CLLocationDegrees
    var companions = Array<String?>()
    
    init(id: String, owner: User, date: String, sourceAddress: String, destinationAddress: String,
         firstLongitude: CLLocationDegrees, firstLatitude: CLLocationDegrees, secondLongitude: CLLocationDegrees, secondLatitude: CLLocationDegrees) {
        self.id = id
        self.owner = owner
        self.date = date
        self.sourceAddress = sourceAddress
        self.destinationAddress = destinationAddress
        self.firstLatitude = firstLatitude
        self.firstLongitude = firstLongitude
        self.secondLatitude = secondLatitude
        self.secondLongitude = secondLongitude
        
        companions.append(owner.uid)
    }
    
    
}

