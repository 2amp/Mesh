//
//  ADTableViewController.swift
//  Mesh
//
//  Created by Daniel Pak on 4/3/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit

class ADTableViewController: UITableViewController{

    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
                "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
                "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
                "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
                "Pear", "Pineapple", "Raspberry", "Strawberry"]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
