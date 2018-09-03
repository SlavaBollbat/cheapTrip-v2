//
//  MainViewController.swift
//  CheapTrip
//
//  Created by Слава on 19.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import UserNotifications

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var rides = Array<Ride>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeRides()
        tableView.reloadData()
        
    }
    
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "showLogInVC", sender: self)
    }
    
    
    func removeRoute() {
        
        let overlays = mapView.overlays
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        mapView.removeOverlays(overlays)
        
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
                    
                    if companions.contains(currentUserUID) {
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
    
    func createRoute(firstCoordinate: CLLocationCoordinate2D, secondCoordinate: CLLocationCoordinate2D, firstAddress: String, secondAddress: String) {
        
        let firstAnnotation = MKPointAnnotation()
        firstAnnotation.title = firstAddress
        firstAnnotation.coordinate = firstCoordinate
        
        let secondAnnotation = MKPointAnnotation()
        secondAnnotation.title = secondAddress
        secondAnnotation.coordinate = secondCoordinate
        
        self.mapView.showAnnotations([firstAnnotation, secondAnnotation], animated: true)
        
        let firstItem = MKMapItem(placemark: MKPlacemark(coordinate: firstCoordinate))
        let secondItem = MKMapItem(placemark: MKPlacemark(coordinate: secondCoordinate))
        
        let request = MKDirectionsRequest()
        request.source = firstItem
        request.destination = secondItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error{
                    print(error)
                }
                return
            }
            let route = response.routes.first!
            self.mapView.add(route.polyline , level: .aboveRoads)
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
    
    func removeNotifications(withIdentifiers identifiers: [String]){
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
}



extension MainViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "activeRideCell", for: indexPath) as? ActiveRidesCell else {return UITableViewCell()}
        
        if rides[indexPath.row].owner.uid == UserService.currentUser?.uid {
            cell.setOwnerFields(ride: rides[indexPath.row])
            cell.accessoryType = .checkmark
        } else {
            
            cell.set(ride: rides[indexPath.row])
        }
        
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        removeRoute()
        
        let firstLatitude = rides[indexPath.row].firstLatitude
        let firstLongitude = rides[indexPath.row].firstLongitude
        let secondLatitude = rides[indexPath.row].secondLatitude
        let secondLongitude = rides[indexPath.row].secondLongitude
        
        
        let firstCoordinate = CLLocationCoordinate2DMake(firstLatitude, firstLongitude)
        let secondCoordinate = CLLocationCoordinate2DMake(secondLatitude, secondLongitude)
        let firstAddress = rides[indexPath.row].sourceAddress
        let secondAddress = rides[indexPath.row].destinationAddress
        
        
        createRoute(firstCoordinate: firstCoordinate, secondCoordinate: secondCoordinate, firstAddress: firstAddress, secondAddress: secondAddress)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let ride = self.rides[indexPath.row]
        let rideRef = Database.database().reference().child("rides").child(ride.id)
        
        let unsubscribe = UITableViewRowAction(style: .default, title: "Unsubscribe") { (action, indexPath) in
            
            var newArray = ride.companions
            
            if let index = newArray.index(of:UserService.currentUser?.uid) {
                newArray.remove(at: index)
            }
            
            rideRef.updateChildValues(["companions" : newArray])
            self.removeRoute()
            
            self.removeNotifications(withIdentifiers: [ride.destinationAddress])
            
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            rideRef.removeValue()
            self.removeRoute()
            
            self.removeNotifications(withIdentifiers: [ride.destinationAddress])
            
        }
        
        let call = UITableViewRowAction(style: .default, title: "Call") { (action, indexPath) in
            
            self.showAlert(phoneNumber: ride.owner.phonenumber)
            
        }
        call.backgroundColor = .green
        
        if rides[indexPath.row].owner.uid == UserService.currentUser!.uid {
            return [delete]
        } else {
            return [unsubscribe, call]
        }
        
    }
    
    
}

extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = .red
        return renderer
    }
    
}
