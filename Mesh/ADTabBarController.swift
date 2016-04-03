
//
//  TabBarController.swift
//  Mesh
//
//  Created by Daniel Pak on 4/3/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit

class ADTabBarController: UITabBarController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.boolForKey("isSet"){
            selectedIndex = 0
        }
        else {
            selectedIndex = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
