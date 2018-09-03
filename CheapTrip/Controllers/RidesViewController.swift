//
//  RidesViewController.swift
//  CheapTrip
//
//  Created by Слава on 30.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import UserNotifications

class RidesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var rides = Array<Ride>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        observeRides()
        tableView.reloadData()
    }
    
    func observeRides() {
        let rideRef = Database.database().reference().child("rides")
        
        guard let currentUserUID = UserService.currentUser?.uid else { return }
        
        rideRef.observe(.value) { (snapshot) in
            
            var tempRides = Array<Ride>()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String: Any],
                    
                    let secondLongitude = dict["secondLongitude"] as? CLLocationDegrees,
                    let sourceAddress = dict["sourceAddress"] as? String,
                    let companions = dict["companions"] as? [String],
                    let firstLatitude = dict["firstLatitude"] as? CLLocationDegrees,
                    let owner = dict["owner"] as? [String: Any],
                    let phonenumber = owner["phonenumber"] as? String,
                    let photoURL = owner["photoURL"] as? String,
                    let url = URL(string: photoURL),
                    let uid = owner["uid"] as? String,
                    let username = owner["username"] as? String,
                    let date = dict["date"] as? String,
                    let secondLatitude = dict["secondLatitude"] as? CLLocationDegrees,
                    let destinationAddress = dict["destinationAddress"] as? String,
                    let firstLongitude = dict["firstLongitude"] as? CLLocationDegrees {
                    
                    if !companions.contains(currentUserUID) {
                        let owner = User(uid: uid, username: username, phoneNumber: phonenumber, photoURL: url)
                        
                        let ride = Ride(id: childSnapshot.key, owner: owner, date: date, sourceAddress: sourceAddress, destinationAddress: destinationAddress, firstLongitude: firstLongitude, firstLatitude: firstLatitude, secondLongitude: secondLongitude, secondLatitude: secondLatitude)
                        
                        tempRides.append(ride)
                        
                    }
                    
                }
                
            }
            
            self.rides = tempRides
            self.tableView.reloadData()
        }
    }
    
    func showAlert(phoneNumber: String) {
        
        let alertController = UIAlertController(title: nil, message: "Choose action", preferredStyle: .actionSheet)
        
        let call = UIAlertAction(title: "Call: \(phoneNumber)", style: .default) { (action) in
            let alertC = UIAlertController(title: nil, message: "The subscriber is not available now please call back later", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertC.addAction(ok)
            self.present(alertC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(call)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func sendNotification(date: String, identifier: String, phonenumber: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        guard let someDate = dateFormatter.date(from: date) else { return }
        print(someDate)
        let content = UNMutableNotificationContent()
        content.title = "Ta-dam"
        content.body = "It's time to call \(phonenumber) and go to \(identifier)!"
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: someDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
}

extension RidesViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allRidesCell", for: indexPath)
            as? AllRidesCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        cell.set(ride: rides[indexPath.row])
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let ride = self.rides[indexPath.row]
        let rideRef = Database.database().reference().child("rides").child(ride.id)
        
        let subscribe = UITableViewRowAction(style: .default, title: "Subscribe") { (action, indexPath) in
            
            var newArray = ride.companions
            newArray.append(UserService.currentUser?.uid)
            rideRef.updateChildValues(["companions" : newArray])
            
            self.sendNotification(date: ride.date, identifier: ride.destinationAddress, phonenumber: ride.owner.phonenumber)

            
        }
        
        let call = UITableViewRowAction(style: .default, title: "Call") { (action, indexPath) in
            
            self.showAlert(phoneNumber: ride.owner.phonenumber)
            
        }
        
        subscribe.backgroundColor = .blue
        call.backgroundColor = .green
        return [subscribe, call]
    }
    
}
