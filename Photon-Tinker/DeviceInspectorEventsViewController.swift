//
//  DeviceInspectorEventsViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 spark. All rights reserved.
//



class DeviceInspectorEventsViewController: DeviceInspectorChildViewController {

    @IBOutlet weak var deviceEventsTableView: UITableView!
    
    @IBOutlet weak var noEventsLabel: UILabel!
    
    var events : [SparkEvent]?
    
    var subscribeId : AnyObject?
    
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        return nil
//    }
    
    
    func subscribeToDeviceEvents() {
        self.subscribeId = SparkCloud.sharedInstance().subscribeToDeviceEventsWithPrefix(nil, deviceID: self.device!.id, handler: {[unowned self] (event:SparkEvent?, error:NSError?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                if let e = event {
                    if self.events == nil {
                        self.events = [SparkEvent]()
                        dispatch_async(dispatch_get_main_queue(),{
                            self.noEventsLabel.hidden = true
                        })
                    }
                    // insert new event to datasource
                    self.events?.insert(e, atIndex: 0)
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        // add new event row on top
                        self.deviceEventsTableView.beginUpdates()
                        self.deviceEventsTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                        self.deviceEventsTableView.endUpdates()
                        
                    })
                }
            }
            })
    }
    
    func unsubscribeFromDeviceEvents() {
        SparkCloud.sharedInstance().unsubscribeFromEventWithID(self.subscribeId!)
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToDeviceEvents()
        
    }
    
    var paused : Bool = false
    
    @IBAction func playPauseButtonTapped(sender: AnyObject) {
        if paused {
            paused = false
            playPauseButton.setImage(UIImage(named: "imgPause"), forState: .Normal)
            subscribeToDeviceEvents()
        } else {
            paused = true
            playPauseButton.setImage(UIImage(named: "imgPlay"), forState: .Normal)
            unsubscribeFromDeviceEvents()
        }
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        let deleteEventsAlert = UIAlertController(title: "Clear all events", message: "All events data will be lost. Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteEventsAlert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: {[unowned self] (action: UIAlertAction!) in
            
            self.events = nil
            self.deviceEventsTableView.reloadData()
            self.noEventsLabel.hidden = false
            
        }))
        
        deleteEventsAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action: UIAlertAction!) in
//            print("Handle Cancel Logic here")
        }))
        
        presentViewController(deleteEventsAlert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromDeviceEvents()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let e = self.events {
            return e.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // kill section
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105.0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DeviceEventTableViewCell? = self.deviceEventsTableView.dequeueReusableCellWithIdentifier("eventCell") as? DeviceEventTableViewCell
        
        if let eventsArr = self.events {
            cell?.event = eventsArr[indexPath.row]
        }
        
        return cell!
        
    }
    
    
    

    
 
}
