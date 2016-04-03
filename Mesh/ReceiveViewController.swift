//
//  ViewController.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class ReceiveViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    @IBOutlet var lblAdDetails: UILabel!

    let locationManager = CLLocationManager()
    var beaconRegion: CLBeaconRegion!
    var lastFoundBeacon: CLBeacon = CLBeacon()
    var lastProximity: CLProximity = CLProximity.Unknown
    var lastAdvertiserMM: (major: Int, minor: Int) = (0, 0)
    let defaults = NSUserDefaults.standardUserDefaults()

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
        beaconRegion.notifyEntryStateOnDisplay = false

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

                if lastAdvertiserMM.major != lastFoundBeacon.major.integerValue || lastAdvertiserMM.minor != lastFoundBeacon.minor.integerValue {

                    lastAdvertiserMM.major = lastFoundBeacon.major.integerValue
                    lastAdvertiserMM.minor = lastFoundBeacon.minor.integerValue
                    let query = PFQuery(className: "MMtoADId").whereKey("major", equalTo: lastAdvertiserMM.major).whereKey("minor", equalTo: lastAdvertiserMM.minor)
                    query.findObjectsInBackgroundWithBlock({ (result, error) in
                        let adid = result![0]["adid"] as! String
                        let adQuery = PFQuery(className: "ADProfile").whereKey("objectId", equalTo: adid)
                        adQuery.findObjectsInBackgroundWithBlock({ (result, error) in
                            let ad = result![0]
                            let name = ad["name"] as! String
                            let aff = ad["affiliation"] as! String
                            let conn = PFObject(className: "Connection",
                                dictionary: [
                                    "advertiser": ad.objectId!,
                                    "client": self.defaults.stringForKey("objectIdCL")!
                                ])
                            conn.saveInBackgroundWithBlock({ (success, error) in
                                if success {
                                    print("Logged a connection between AD: \(ad.objectId!) and CL: \(self.defaults.stringForKey("objectIdCL")!)")
                                }
                            })
                            self.lblAdDetails.text = "AD Details\nName: \(name)\nAffiliation: \(aff)"
                        })
                    })


                }

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
            }
        }
        
        lblBeaconDetails.hidden = shouldHideBeaconDetails
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

