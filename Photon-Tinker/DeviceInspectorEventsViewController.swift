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
    
    var subscribeId : Any?
    
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        return nil
//    }
    
    @IBOutlet weak var eventFilterSearchBar: UISearchBar!
    
    func subscribeToDeviceEvents() {
        
        self.subscribeId = SparkCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: nil, deviceID: self.device!.id, handler: {[weak self] (event:SparkEvent?, error:Error?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                
                DispatchQueue.main.async(execute: {
                    // sequence must be all on the same thread otherwise we get NSInternalInconsistency exception on insertRowsAtIndexPaths
                    if let s = self {
                        if let e = event {
                            if s.events == nil {
                                s.events = [SparkEvent]()
                                s.filteredEvents = [SparkEvent]()
                                s.noEventsLabel.isHidden = true
                            }
                            // insert new event to datasource
                            s.events?.insert(e, at: 0)
                            if s.filtering {
                                s.filterEvents()
                                s.deviceEventsTableView.reloadData()
                            } else {
                                if !s.view.isHidden {
                                    // add new event row on top
                                    
                                    s.deviceEventsTableView.beginUpdates()
                                    s.deviceEventsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
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
            SparkCloud.sharedInstance().unsubscribeFromEvent(withID: sid)
        }
    }
    
 
    @IBOutlet weak var clearEventsButton: UIButton!
    var paused : Bool = false
    var filtering : Bool = false
    
    
    override func viewWillAppear(_ animated: Bool) {
            subscribeToDeviceEvents()
    }
    
    
    override func showTutorial() {
        
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.7 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if !self.view.isHidden {
                    // viewController is visible
                   
//                    var tutorial = YCTutorialBox(headline: "Clear events", withHelpText: "Tap the trash can icon to remove all the events from the list.")
//                    tutorial.showAndFocusView(self.clearEventsButton)
                    
                    // 3
                    var tutorial = YCTutorialBox(headline: "Play and pause", withHelpText: "Tap play/pause button to pause the events stream momentarily. Events published while stream is paused will not be added to the list.")
                    tutorial?.showAndFocus(self.playPauseButton)
                    
                    // 2
                    tutorial = YCTutorialBox(headline: "Search events", withHelpText: "Tap filter text field and type text to filter the events list and show only events containing the search text. Filtering is performed on event name and data.")
                    
                    tutorial?.showAndFocus(self.eventFilterSearchBar)
                    
                    
                    // 1
                    tutorial = YCTutorialBox(headline: "Device Events", withHelpText: "This is a searchable log of the events your device published to the cloud. Tap the blue clipboard button to copy event payload to your clipboard.")
                    
                    tutorial?.showAndFocus(self.deviceEventsTableView)
                    
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                    self.deviceEventsTableView.reloadData()
                }
                
            }
        }
    }

    @IBOutlet weak var backgroundView: UIView!
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.eventFilterSearchBar.text = ""
        self.eventFilterSearchBar.showsCancelButton = false
        self.backgroundView.backgroundColor = UIColor.white
        self.filtering = false
        self.deviceEventsTableView.reloadData()
    }
    
    var filterText : String?
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.filtering = (searchText != "")
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.25, animations: {
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
        SEGAnalytics.shared().track("Device Inspector: event filter typing")
        DispatchQueue.main.async {
            self.deviceEventsTableView.reloadData()
        }

    }

    func filterEvents() {
        if self.filtering {
            if let eventsArr = self.events {
                self.filteredEvents = eventsArr.filter({$0.event.contains(self.filterText!) || $0.data!.contains(self.filterText!)}) // filter for both name and data
            }
        }
    }
    


@IBAction func playPauseButtonTapped(_ sender: AnyObject) {
        if paused {
            paused = false
            SEGAnalytics.shared().track("Device Inspector: event stream play")
            playPauseButton.setImage(UIImage(named: "imgPause"), for: UIControlState())
            subscribeToDeviceEvents()
        } else {
            paused = true
            SEGAnalytics.shared().track("Device Inspector: event stream pause")
            playPauseButton.setImage(UIImage(named: "imgPlay"), for: UIControlState())
            unsubscribeFromDeviceEvents()
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        
        let dialog = ZAlertView(title: "Clear all events", message: "All events data will be deleted. Are you sure?", isOkButtonLeft: true, okButtonText: "No", cancelButtonText: "Yes",
                                okButtonHandler: { alertView in
                                    alertView.dismiss()
                                    
            },
                                cancelButtonHandler: { alertView in
                                    alertView.dismiss()
                                    self.events = nil
                                    self.filteredEvents = nil
                                    self.deviceEventsTableView.reloadData()
                                    self.noEventsLabel.isHidden = false
                                    SEGAnalytics.shared().track("Device Inspector: events cleared")

            }
        )
        
        
        
        dialog.show()

    }
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromDeviceEvents()
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

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
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // kill section
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 105.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell : DeviceEventTableViewCell? = self.deviceEventsTableView.dequeueReusableCell(withIdentifier: "eventCell") as? DeviceEventTableViewCell
        
        if filtering {
            if let eventsArr = self.filteredEvents {
                cell?.event = eventsArr[(indexPath as NSIndexPath).row]
            }
        } else {
            if let eventsArr = self.events {
                cell?.event = eventsArr[(indexPath as NSIndexPath).row]
            }
        }

        
        return cell!
        
    }
    
    
    

    
 
}
