//
//  BroadcastViewController.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class BroadcastViewController: UIViewController, CBPeripheralManagerDelegate {
    @IBOutlet var btnAction: UIButton!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblBTStatus: UILabel!
    @IBOutlet var majorLbl: UILabel!
    @IBOutlet var minorLbl: UILabel!

    var major = 1
    var minor = 1

    let defaults = NSUserDefaults.standardUserDefaults()

    let uuid = NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")!
    var beaconRegion: CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var dataDictionary = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)

        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("isSet: \(defaults.boolForKey("isSet"))")
        if defaults.boolForKey("isSet") {
            major = defaults.integerForKey("major")
            minor = defaults.integerForKey("minor")
            print("major: \(major) minor: \(minor)")
            majorLbl.text = "Major: \(major)"
            minorLbl.text = "Major: \(minor)"
        } else {
            majorLbl.text = "Major: ?"
            minorLbl.text = "Major: ?"
        }


    }

    // MARK: Custom method implementation

    func handleSwipeGestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer) {

    }


    // MARK: IBAction method implementation

    @IBAction func switchBroadcastingState(sender: AnyObject) {
        if !isBroadcasting {
            if bluetoothPeripheralManager.state == .PoweredOn {
                beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: "com.2amp.mesh")
                dataDictionary = beaconRegion.peripheralDataWithMeasuredPower(nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : AnyObject])

                btnAction.setTitle("Stop", forState: .Normal)
                lblStatus.text = "Broadcasting..."
                isBroadcasting = true
            }
        } else {
            bluetoothPeripheralManager.stopAdvertising()

            btnAction.setTitle("Start", forState: UIControlState.Normal)
            lblStatus.text = "Stopped"

            isBroadcasting = false
        }
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        var statusMessage = ""

        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOn:
            statusMessage = "Bluetooth Status: Turned On"

        case CBPeripheralManagerState.PoweredOff:
            if isBroadcasting {
                switchBroadcastingState(self)
            }
            statusMessage = "Bluetooth Status: Turned Off"

        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"

        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"

        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"

        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        lblBTStatus.text = statusMessage
    }
}