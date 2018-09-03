//
//  NewRideViewController.swift
//  CheapTrip
//
//  Created by Слава on 21.08.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import UserNotifications

class NewRideViewController: UIViewController {
    
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var showDirectionButton: UIButton!
    
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var firstCoordinate = CLLocationCoordinate2D()
    var secondCoordinate = CLLocationCoordinate2D()
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        sourceTextField.delegate = self
        destinationTextField.delegate = self
        
        showDirectionButton.isEnabled = false
        showDirectionButton.alpha = 0.5
        
        createButton.isEnabled = false
        createButton.alpha = 0.5

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        sourceTextField.addTarget(self, action: #selector(sourceTextFieldDidChanged), for: .editingChanged)
        destinationTextField.addTarget(self, action: #selector(destinationTextFieldDidChanged), for:.editingChanged)
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker: )), for: .valueChanged)
        dateTextField.inputView = datePicker
        
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .full
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"

        dateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
        
    }
    
    @objc func sourceTextFieldDidChanged() {
        geocoder.geocodeAddressString(sourceTextField.text!) { (placemarks, error) in
            if error != nil {
                print("\(error!)")
            }
            
            if placemarks != nil {
                if let placemark = placemarks?.first {
                    self.firstCoordinate = placemark.location!.coordinate
                }
            }
        }
        
    }
    
    @objc func destinationTextFieldDidChanged() {
        geocoder.geocodeAddressString(destinationTextField.text!) { (placemarks, error) in
            if error != nil {
                print("\(error!)")
            }
            
            if placemarks != nil {
                if let placemark = placemarks?.first {
                    self.secondCoordinate = placemark.location!.coordinate
                }
            }
        }
        
        if destinationTextField.text != "", sourceTextField.text != "", dateTextField.text != "" {
            showDirectionButton.isEnabled = true
            showDirectionButton.alpha = 1
        }
        
    }
    func removeRoute() {
        
        let overlays = mapView.overlays
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        mapView.removeOverlays(overlays)
        
    }
    
    @IBAction func getDirectionPressed(_ sender: UIButton) {
        
        removeRoute()
        
        if let firstAddress = sourceTextField.text, let secondAdress = destinationTextField.text {
            
            createRoute(firstCoordinate: self.firstCoordinate, secondCoordinate: self.secondCoordinate,
                        firestAddress: firstAddress, secondAddress: secondAdress)
        }
        
        createButton.isEnabled = true
        createButton.alpha = 1
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        
        removeRoute()
        
        guard let user = UserService.currentUser else { return }
        
        let rideObject = [
            "owner": [
                "uid": user.uid,
                "username": user.username,
                "phonenumber": user.phonenumber,
                "photoURL": user.photoURL.absoluteString
            ],
            "date": dateTextField.text!,
            "sourceAddress": sourceTextField.text!,
            "destinationAddress": destinationTextField.text!,
            "firstLongitude": firstCoordinate.longitude,
            "firstLatitude": firstCoordinate.latitude,
            "secondLongitude": secondCoordinate.longitude,
            "secondLatitude": secondCoordinate.latitude,
            "companions": [user.uid]
        ] as [String: Any]
        
        let rideRef = Database.database().reference().child("rides").childByAutoId()
        rideRef.setValue(rideObject)
        
        sendNotification(date: dateTextField.text!, identifier: destinationTextField.text!)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func createRoute(firstCoordinate: CLLocationCoordinate2D, secondCoordinate: CLLocationCoordinate2D, firestAddress: String, secondAddress: String) {
        
        let firstAnnotation = MKPointAnnotation()
        firstAnnotation.title = firestAddress
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
    
    func sendNotification(date: String, identifier: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        guard let someDate = dateFormatter.date(from: date) else { return }
        print(someDate)
        let content = UNMutableNotificationContent()
        content.title = "Ta-dam"
        content.body = "It's time to call taxi and go to \(identifier)! Please, don't forget to remove your trip!"
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: someDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }

}

extension NewRideViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = .red
        return renderer
    }
    
    
}

extension NewRideViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentlocation = locations.last!
        let currentRadius : CLLocationDistance = 500.0
        let currentRegion = MKCoordinateRegionMakeWithDistance(currentlocation.coordinate, currentRadius * 2, currentRadius * 2)
        
        self.mapView.setRegion(currentRegion, animated: true)
        self.mapView.showsUserLocation = true
    }
}

extension NewRideViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sourceTextField.resignFirstResponder()
        destinationTextField.resignFirstResponder()

        
        return true
    }
}


