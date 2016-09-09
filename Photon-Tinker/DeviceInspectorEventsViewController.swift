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
        
        self.subscribeId = SparkCloud.sharedInstance().subscribeToDeviceEventsWithPrefix(nil, deviceID: self.device!.id, handler: {[weak self] (event:SparkEvent?, error:NSError?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                
                dispatch_async(dispatch_get_main_queue(),{
                    // sequence must be all on the same thread otherwise we get NSInternalInconsistency exception on insertRowsAtIndexPaths
                    if let s = self {
                        if let e = event {
                            if s.events == nil {
                                s.events = [SparkEvent]()
                                s.filteredEvents = [SparkEvent]()
                                s.noEventsLabel.hidden = true
                            }
                            // insert new event to datasource
                            s.events?.insert(e, atIndex: 0)
                            if s.filtering {
                                s.filterEvents()
                                s.deviceEventsTableView.reloadData()
                            } else {
                                if !s.view.hidden {
                                    // add new event row on top
                                    
                                    s.deviceEventsTableView.beginUpdates()
                                    s.deviceEventsTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                                    s.deviceEventsTableView.endUpdates()
                                } else {
                                    s.deviceEventsTableView.reloadData()
                                }
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
    
 
    @IBOutlet weak var clearEventsButton: UIButton!
    var paused : Bool = false
    var filtering : Bool = false
    
    
    override func viewWillAppear(animated: Bool) {
            subscribeToDeviceEvents()
    }
    
    
    override func showTutorial() {
        
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                if !self.view.hidden {
                    // viewController is visible
                   
//                    var tutorial = YCTutorialBox(headline: "Clear events", withHelpText: "Tap the trash can icon to remove all the events from the list.")
//                    tutorial.showAndFocusView(self.clearEventsButton)
                    
                    // 3
                    var tutorial = YCTutorialBox(headline: "Play and pause", withHelpText: "Tap play/pause button to pause the events stream momentarily. Events published while stream is paused will not be added to the list.")
                    tutorial.showAndFocusView(self.playPauseButton)
                    
                    // 2
                    tutorial = YCTutorialBox(headline: "Search events", withHelpText: "Tap filter text field and type text to filter the events list and show only events containing the search text. Filtering is performed on event name and data.")
                    
                    tutorial.showAndFocusView(self.eventFilterSearchBar)
                    
                    
                    // 1
                    tutorial = YCTutorialBox(headline: "Device Events", withHelpText: "This is a searchable log of the events your device published to the cloud. Tap the blue clipboard button to copy event payload to your clipboard.")
                    
                    tutorial.showAndFocusView(self.deviceEventsTableView)
                    
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                    self.deviceEventsTableView.reloadData()
                }
                
            }
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
        SEGAnalytics.sharedAnalytics().track("Device Inspector: event filter typing")
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
            SEGAnalytics.sharedAnalytics().track("Device Inspector: event stream play")
            playPauseButton.setImage(UIImage(named: "imgPause"), forState: .Normal)
            subscribeToDeviceEvents()
        } else {
            paused = true
            SEGAnalytics.sharedAnalytics().track("Device Inspector: event stream pause")
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
                                    SEGAnalytics.sharedAnalytics().track("Device Inspector: events cleared")

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
