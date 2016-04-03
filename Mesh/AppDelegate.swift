//
//  AppDelegate.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")!, identifier: "com.2amp.mesh")
    let defaults = NSUserDefaults.standardUserDefaults()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

//        let domain = NSBundle.mainBundle().bundleIdentifier
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domain!)

        if let _ = launchOptions?[UIApplicationLaunchOptionsLocationKey] {
            locationManager.delegate = self
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }

        // Connect to Parse server
        let configuration = ParseClientConfiguration {
            $0.applicationId = "myAppId"
            $0.server = "http://66.228.37.35:1337/parse"
        }
        Parse.initializeWithConfiguration(configuration)

        return true
    }

    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        let notification = UILocalNotification()
        switch state {
        case .Inside:
            notification.alertBody = "You are inside region \(region.identifier)"
        case .Outside:
            notification.alertBody = "You are outside region \(region.identifier)"
        case .Unknown:
            notification.alertBody = "Unknown \(region.identifier)"
        }
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "didRangeBeacons"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        let foundBeacons = beacons
        if foundBeacons.count > 0 {
            let closestBeacon = foundBeacons[0]
            let query = PFQuery(className: "MMtoADId").whereKey("major", equalTo: closestBeacon.major).whereKey("minor", equalTo: closestBeacon.minor)
            query.findObjectsInBackgroundWithBlock({ (result, error) in
                let adid = result![0]["adid"] as! String
                let adQuery = PFQuery(className: "ADProfile").whereKey("objectId", equalTo: adid)
                adQuery.findObjectsInBackgroundWithBlock({ (result, error) in
                    let ad = result![0]
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
                })
            })
        }
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "Beacon in range"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "No beacons in range"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.2amp.Mesh" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Mesh", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

