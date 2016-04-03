//
//  ADTableViewController.swift
//  Mesh
//
//  Created by Daniel Pak on 4/3/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import Parse

class ADTableViewController: UITableViewController {
    var data: [PFObject] = []
    let defaults = NSUserDefaults.standardUserDefaults()

    var expandedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        let query = PFQuery(className: "Connection").whereKey("advertiser", equalTo: defaults.stringForKey("objectId")!)
        query.findObjectsInBackgroundWithBlock { (result, error) in
            var queries: [PFQuery] = []
            for obj in result! {
                print(obj.objectId!)
                queries.append(PFQuery(className: "CLProfile").whereKey("objectId", equalTo: obj["client"] as! String))
            }
            PFQuery.orQueryWithSubqueries(queries).findObjectsInBackgroundWithBlock({ (clients, error) in
                print(clients!.count)
                self.data = clients!
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
}
