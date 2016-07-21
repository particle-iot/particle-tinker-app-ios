//
//  DeviceInspectorEventsViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 spark. All rights reserved.
//



class DeviceInspectorEventsViewController: DeviceInspectorChildViewController, UISearchBarDelegate {

    @IBOutlet weak var deviceEventsTableView: UITableView!
    
    @IBOutlet weak var noEventsLabel: UILabel!
    
    var events : [SparkEvent]?
    var filteredEvents : [SparkEvent]?
    
    var subscribeId : AnyObject?
    
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        return nil
//    }
    
    @IBOutlet weak var eventFilterSearchBar: UISearchBar!
    
    func subscribeToDeviceEvents() {
        
        self.subscribeId = SparkCloud.sharedInstance().subscribeToDeviceEventsWithPrefix(nil, deviceID: self.device!.id, handler: {[unowned self] (event:SparkEvent?, error:NSError?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                
                dispatch_async(dispatch_get_main_queue(),{
                    // sequence must be all on the same thread otherwise we get NSInternalInconsistency exception on insertRowsAtIndexPaths
                    
                    if let e = event {
                        if self.events == nil {
                            self.events = [SparkEvent]()
                            self.filteredEvents = [SparkEvent]()
                            self.noEventsLabel.hidden = true
                        }
                        // insert new event to datasource
                        self.events?.insert(e, atIndex: 0)
                        if self.filtering {
                            self.filterEvents()
                            self.deviceEventsTableView.reloadData()
                        } else {
                            if !self.view.hidden {
                                    // add new event row on top
                                
                                    self.deviceEventsTableView.beginUpdates()
                                    self.deviceEventsTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                                    self.deviceEventsTableView.endUpdates()
                                    
                            }
                        }
                    }
                })
            }
            })
    }
    
    func unsubscribeFromDeviceEvents() {
        if let sid = self.subscribeId {
            SparkCloud.sharedInstance().unsubscribeFromEventWithID(sid)
        }
    }
    
 
    var paused : Bool = false
    var filtering : Bool = false
    var firstTime : Bool = true
    
    func viewDidAppearFirstTime() {
        if firstTime {
            subscribeToDeviceEvents()
            firstTime = false
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.eventFilterSearchBar.text = ""
        self.eventFilterSearchBar.showsCancelButton = false
        self.backgroundView.backgroundColor = UIColor.whiteColor()
        self.filtering = false
        self.deviceEventsTableView.reloadData()
    }
    
    var filterText : String?
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        self.filtering = (searchText != "")
        
        dispatch_async(dispatch_get_main_queue()) {
            
            UIView.animateWithDuration(0.25, animations: {
                if self.filtering {
                    self.eventFilterSearchBar.showsCancelButton = true
                    self.backgroundView.backgroundColor = UIColor.color("#D5D5D5")
                    self.filtering = true
                } else {
                    self.searchBarCancelButtonClicked(searchBar)
                }
            })
            // ANIMATE TABLE
        }
        
        self.filterText = searchText
        self.filterEvents()
        dispatch_async(dispatch_get_main_queue()) {
            self.deviceEventsTableView.reloadData()
        }

    }

    func filterEvents() {
        if self.filtering {
            if let eventsArr = self.events {
                self.filteredEvents = eventsArr.filter({$0.event.containsString(self.filterText!) || $0.data!.containsString(self.filterText!)}) // filter for both name and data
            }
        }
    }
    


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
        
        let dialog = ZAlertView(title: "Clear all events", message: "All events data will be deleted. Are you sure?", isOkButtonLeft: true, okButtonText: "No", cancelButtonText: "Yes",
                                okButtonHandler: { alertView in
                                    alertView.dismiss()
                                    
            },
                                cancelButtonHandler: { alertView in
                                    alertView.dismiss()
                                    self.events = nil
                                    self.filteredEvents = nil
                                    self.deviceEventsTableView.reloadData()
                                    self.noEventsLabel.hidden = false

            }
        )
        
        
        
        dialog.show()

    }
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromDeviceEvents()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if filtering {
            if let e = self.filteredEvents {
                return e.count
            } else {
                return 0
            }
        } else {
            if let e = self.events {
                return e.count
            } else {
                return 0
            }
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
        
        if filtering {
            if let eventsArr = self.filteredEvents {
                cell?.event = eventsArr[indexPath.row]
            }
        } else {
            if let eventsArr = self.events {
                cell?.event = eventsArr[indexPath.row]
            }
        }

        
        return cell!
        
    }
    
    
    

    
 
}
