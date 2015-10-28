//
//  PlacesListViewController.swift
//  Places
//
//  Created by William Izzo on 27/10/15.
//  Copyright © 2015 wizzo s.l.d.s. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PlacesListViewController : UITableViewController {
    var availablePlaces : Results<Place>!
    override func viewWillAppear(animated: Bool) {
        let realm = try! Realm()
        
        self.availablePlaces = realm.objects(Place)
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availablePlaces.count
    }
    
    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("place-tvr", forIndexPath: indexPath);
            
            if let placeTVR = cell as? PlaceTVR {
                let place = self.availablePlaces[indexPath.row]
                placeTVR.titleLabel.text = place.title
                placeTVR.addressLabel.text = ""
            }
            
            return cell
    }
}