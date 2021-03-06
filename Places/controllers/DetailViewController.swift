//
//  DetailViewController.swift
//  Places
//
//  Created by William Izzo on 07/11/15.
//  Copyright © 2015 wizzo s.l.d.s. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class DetailViewController : UIViewController {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressButton : UIButton!
    @IBOutlet weak var tagButton : UIButton!
    
    @IBOutlet weak var scrimView: ScrimView!

    var place : Place!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressButton.titleLabel?.numberOfLines = 0
        self.tagButton.titleLabel?.numberOfLines = 0
        
        self.scrimView.gradientColors = [
            UIColor(white: 0.0, alpha: 0.0),
            UIColor(white: 0.0, alpha: 0.6),
        ]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            forBarMetrics: UIBarMetrics.Default)
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let settingsBarButton = UIBarButtonItem(
            image: UIImage(named: "ic_build_36pt"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "showItemAction:")
        
        
        self.navigationItem.rightBarButtonItem = settingsBarButton
        
        let imageUID = self.place.imageUID
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            if let imageData = readDataInLibraryPath(imageUID) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.placeImageView.image = UIImage(data: imageData)
                })
            }
        }
        
        
        self.titleLabel.text = self.place.title
        self.addressButton.setTitle(self.place.longAddress, forState: UIControlState.Normal)
        
        var tagString = String()
        
        if self.place.tags.count == 0 {
            tagString = "Add tags"
        } else {
            
            for tag in self.place.tags {
                if self.place.tags.last != tag {
                    tagString += tag.name + ",\n"
                }else {
                    tagString += tag.name
                }
            }
        }
        
        self.tagButton.setTitle(tagString, forState: UIControlState.Normal)
    }

    @IBAction func cancelButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func directionButton() {
        
        var addressDict : [String:AnyObject]?
        if let addressData = self.place.addressData {
            addressDict = NSKeyedUnarchiver.unarchiveObjectWithData(addressData) as? [String:AnyObject]
        }
        
        let coordinates = CLLocationCoordinate2DMake(self.place.latitude, self.place.longitude)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDict)
        let destination = MKMapItem(placemark: placemark);
        
        destination.name = self.place.title
        
        MKMapItem.openMapsWithItems([destination], launchOptions: nil)
    }
    
    @IBAction func done(segue:UIStoryboardSegue){
        
    }
    
    func showItemAction(sender:UIBarButtonItem) {
        let alertController = UIAlertController(title: "What shall we do?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(
            UIAlertAction(title: "Delete item", style: UIAlertActionStyle.Destructive, handler: { (deleteAction) -> Void in
                // 1.remove item from realm
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    realm.delete(self.place)
                })
                
                // 2.unwind segue
                self.navigationController?.popViewControllerAnimated(true)
            })
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: nil)
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "add-tags-segue" {
            let tagSelectorCtrl = segue.destinationViewController as! TagSelectorTableViewController
            tagSelectorCtrl.place = self.place
        }
    }
}