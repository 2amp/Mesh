//
//  ViewController.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!

    let locationManager = CLLocationManager()
    var beaconRegion: CLBeaconRegion!
    var lastFoundBeacon: CLBeacon = CLBeacon()
    var lastProximity: CLProximity = CLProximity.Unknown

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        let uuid = NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.2amp.mesh")

        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true

        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startMonitoringForRegion(beaconRegion)
    }

//    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
//        locationManager.requestStateForRegion(region)
//        print("Started monitoring")
//    }

//    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
//        switch state {
//        case .Inside:
//            locationManager.startRangingBeaconsInRegion(beaconRegion)
//        case .Outside:
//            locationManager.stopRangingBeaconsInRegion(beaconRegion)
//        case .Unknown:
//            break
//        }
//    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.hidden = false
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.hidden = true
    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var shouldHideBeaconDetails = true

        let foundBeacons = beacons
        if foundBeacons.count > 0 {
            let closestBeacon = foundBeacons[0]
            if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                lastFoundBeacon = closestBeacon
                lastProximity = closestBeacon.proximity

                var proximityMessage: String!
                switch lastFoundBeacon.proximity {
                case CLProximity.Immediate:
                    proximityMessage = "Very close"

                case CLProximity.Near:
                    proximityMessage = "Near"

                case CLProximity.Far:
                    proximityMessage = "Far"

                default:
                    proximityMessage = "Where's the beacon?"
                }

                shouldHideBeaconDetails = false

                lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage
                print(lblBeaconDetails.text)
            }
        }
        
        lblBeaconDetails.hidden = shouldHideBeaconDetails
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

