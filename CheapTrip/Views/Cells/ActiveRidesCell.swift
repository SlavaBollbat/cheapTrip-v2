//
//  ActiveRidesCell.swift
//  CheapTrip
//
//  Created by Слава on 19.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit

class ActiveRidesCell: UITableViewCell {
    
    @IBOutlet weak var sourceAddressLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        userImageView.clipsToBounds = true
        
    }
    
    
    func set(ride: Ride) {
        
        ImageService.downloadImage(withURL: ride.owner.photoURL) { (image) in
            self.userImageView.image = image
        }
        userNameLabel.text = ride.owner.username
        phoneNumberLabel.text = ride.owner.phonenumber
        sourceAddressLabel.text = ride.sourceAddress
        destinationAddressLabel.text = ride.destinationAddress
        dateLabel.text = ride.date
    }
    
    func setOwnerFields(ride: Ride) {
        
        userNameLabel.text = "Personal ride"
        phoneNumberLabel.isHidden = true
        sourceAddressLabel.text = ride.sourceAddress
        destinationAddressLabel.text = ride.destinationAddress
        dateLabel.text = ride.date
    }
}
