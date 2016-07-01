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
    
    
    override func viewWillAppear(animated: Bool) {
        self.subscribeId = SparkCloud.sharedInstance().subscribeToDeviceEventsWithPrefix(nil, deviceID: self.device!.id, handler: {[unowned self] (event:SparkEvent?, error:NSError?) in
            if let _ = error {
                // ?
            } else {
                if let e = event {
                    if self.events == nil {
                        self.events = [SparkEvent]()
                        dispatch_async(dispatch_get_main_queue(),{
                            self.noEventsLabel.hidden = true
                        })
                    }
                    self.events?.insert(e, atIndex: 0)
                    /*
                    dispatch_async(dispatch_get_main_queue(),{
                        UIView.transitionWithView(self.deviceEventsTableView,
                            duration: 0.35,
                            options: .TransitionFlipFromTop,
                            animations:
                            { () -> Void in
                                self.deviceEventsTableView.reloadData()
                            },
                            completion: nil);
                        
                    })
                    */
                    dispatch_async(dispatch_get_main_queue(),{
                        self.deviceEventsTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Bottom)
                    })
                }
            }
            })
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        SparkCloud.sharedInstance().unsubscribeFromEventWithID(self.subscribeId!)
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
            
            let event : SparkEvent = eventsArr[indexPath.row]
            cell?.eventNameValueLabel.text = event.event
            cell?.eventDataValueLabel.text = event.data
            cell?.eventTimeValueLabel.text = event.time.description.stringByReplacingOccurrencesOfString("+0000", withString: "")
        }
        
        return cell!
        
    }
    
    
    

    
 
}
