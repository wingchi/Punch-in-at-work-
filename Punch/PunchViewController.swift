//
//  PunchViewController.swift
//  Punch
//
//  Created by Stephen Wong on 1/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PunchViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    let punchCard = PunchLog()
    
    let arrivalNotificationActionString = "SlackMessagePunchIn"
    let arrivalNotificationCategoryString = "PunchInActionCategory"
    
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func startMonitorAction(sender: AnyObject) {
        
        // Setup Core Location manager
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func monitorLocationChanged(sender: UISwitch) {
        if sender.on {
            // Setup Core Location manager and start monitoring location
            locationManager.delegate = self
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func askForNotificationPermission() {
        let slackMessageAction = UIMutableUserNotificationAction()
        let actionCategory = UIMutableUserNotificationCategory()
        
        slackMessageAction.identifier = arrivalNotificationActionString
        slackMessageAction.destructive = false
        slackMessageAction.title = "Slack It"
        slackMessageAction.activationMode = .Background
        slackMessageAction.authenticationRequired = false
        
        actionCategory.identifier = arrivalNotificationCategoryString
        actionCategory.setActions([slackMessageAction], forContext: .Minimal)
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: [actionCategory])
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func notifyArrival(notificationMessage: String, slackMessage: String) {
        let arrivalNotifier = UILocalNotification()
        
        arrivalNotifier.category = arrivalNotificationCategoryString
        arrivalNotifier.alertBody = notificationMessage
        arrivalNotifier.fireDate = NSDate(timeIntervalSinceNow: 5)
        
        
        
        UIApplication.sharedApplication().presentLocalNotificationNow(arrivalNotifier)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
        
        let intrepidLat: CLLocationDegrees =  42.366358
        let intrepidLong: CLLocationDegrees = -71.077873
        let intrepidRadius: CLLocationDistance = 100
        let intrepidCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: intrepidLat, longitude: intrepidLong)
        let intrepidGeoFence = CLCircularRegion(center: intrepidCenter, radius: intrepidRadius, identifier: "intrepid")
        
        // just some stuff to test if the location is being collected in the foreground or the background
        if UIApplication.sharedApplication().applicationState == .Active {
            NSLog("Foreground: {lat: \(currentLocation.latitude), long: \(currentLocation.longitude)}")
            centerMapOnLocation(manager.location!)
        } else {
            NSLog("Background: {lat: \(currentLocation.latitude), long: \(currentLocation.longitude)}")
        }
        if(intrepidGeoFence.containsCoordinate(currentLocation)) {
            if !punchCard.beenToWork() {
                
                punchCard.punchInToWork()
                
                notifyArrival("Punched in at work", slackMessage: "Let everyone on Slack know")
                
                NSLog("You're at work!")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        askForNotificationPermission()
        // Do any additional setup after loading the view.
    }
    
    //helper method for setting my MapKit View's visible area
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
