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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        
        let nameLbl = cell.viewWithTag(100) as! UILabel
        let emailLbl = cell.viewWithTag(101) as! UILabel
        let affLbl = cell.viewWithTag(102) as! UILabel
        let phoneLbl = cell.viewWithTag(103) as! UILabel

        print(data[indexPath.row].allKeys)
        nameLbl.text = data[indexPath.row]["name"] as? String
        emailLbl.text = data[indexPath.row]["email"] as? String
        affLbl.text = data[indexPath.row]["affiliation"] as? String
        phoneLbl.text = data[indexPath.row]["phone"] as? String
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        if let idx = expandedIndex {
            if indexPath.row == idx {
                expandedIndex = nil
            } else {
                expandedIndex = indexPath.row
            }
        } else {
            expandedIndex = indexPath.row
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.endUpdates()
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let idx = expandedIndex {
            if indexPath.row == idx {
                return 200
            }
        }
        return 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
