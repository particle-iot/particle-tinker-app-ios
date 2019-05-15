//
//  DeviceInspectorEventsViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 particle. All rights reserved.
//



class DeviceInspectorEventsViewController: DeviceInspectorChildViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deviceEventsTableView: UITableView!
    @IBOutlet weak var eventFilterSearchBar: UISearchBar!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var clearEventsButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!

    var events: [ParticleEvent]?
    var filteredEvents: [ParticleEvent]?
    var filterText: String?

    var subscribeId: Any?
    var paused: Bool = false
    var filtering: Bool = false

    func setup(device: ParticleDevice) {
        self.device = device
    }

    override func viewWillAppear(_ animated: Bool) {
        subscribeToDeviceEvents()
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromDeviceEvents()
    }

    override func update() {
        super.update()

        //do nothing
    }

    func subscribeToDeviceEvents() {
        self.subscribeId = ParticleCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: nil, deviceID: self.device.id, handler: {[weak self] (event:ParticleEvent?, error:Error?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                
                DispatchQueue.main.async(execute: {
                    if let self = self {
                        if let e = event {
                            if self.events == nil {
                                self.events = [ParticleEvent]()
                                self.filteredEvents = [ParticleEvent]()
                                self.noEventsLabel.isHidden = true
                            }
                            // insert new event to datasource
                            self.events?.insert(e, at: 0)
                            if self.filtering {
                                self.filterEvents()
                                self.deviceEventsTableView.reloadData()
                            } else {
                                if !self.view.isHidden {
                                    self.deviceEventsTableView.beginUpdates()
                                    self.deviceEventsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                                    self.deviceEventsTableView.endUpdates()
                                } else {
                                    self.deviceEventsTableView.reloadData()
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
            ParticleCloud.sharedInstance().unsubscribeFromEvent(withID: sid)
        }
    }
    
 

    
    override func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.7 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if !self.view.isHidden {
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
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filtering = (searchText != "")
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                if self.filtering {
                    self.eventFilterSearchBar.showsCancelButton = true
                    self.backgroundView.backgroundColor = UIColor(rgb: 0xD5D5D5)
                    self.filtering = true
                } else {
                    self.searchBarCancelButtonClicked(searchBar)
                }
            })
            // ANIMATE TABLE
        }
        
        self.filterText = searchText.lowercased()
        self.filterEvents()

        SEGAnalytics.shared().track("DeviceInspector_EventFilterTyping")
        DispatchQueue.main.async {
            self.deviceEventsTableView.reloadData()
        }

    }

    func filterEvents() {
        if self.filtering {
            if let eventsArr = self.events {
                self.filteredEvents = eventsArr.filter({$0.event.lowercased().contains(self.filterText!) || $0.data!.lowercased().contains(self.filterText!)}) // filter for both name and data
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtering, let e = self.filteredEvents {
            return e.count
        } else if let e = self.events {
            return e.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceEventTableViewCell = self.deviceEventsTableView.dequeueReusableCell(withIdentifier: "eventCell") as! DeviceEventTableViewCell

        if filtering {
            if let eventsArr = self.filteredEvents {
                cell.setup(eventsArr[(indexPath as NSIndexPath).row])
            }
        } else {
            if let eventsArr = self.events {
                cell.setup(eventsArr[(indexPath as NSIndexPath).row])
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }


    @IBAction func playPauseButtonTapped(_ sender: AnyObject) {
        if paused {
            paused = false
            SEGAnalytics.shared().track("DeviceInspector_EventStreamPlay")
            playPauseButton.setImage(UIImage(named: "imgPause"), for: UIControlState())
            subscribeToDeviceEvents()
        } else {
            paused = true
            SEGAnalytics.shared().track("DeviceInspector_EventStreamPause")
            playPauseButton.setImage(UIImage(named: "imgPlay"), for: UIControlState())
            unsubscribeFromDeviceEvents()
        }
    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Clear all events", message: "All events data will be deleted. Are you sure?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            if let self = self {
                self.events = nil
                self.filteredEvents = nil
                self.deviceEventsTableView.reloadData()
                self.noEventsLabel.isHidden = false
            }
            SEGAnalytics.shared().track("DeviceInspector_EventsCleared")
        })

        alert.addAction(UIAlertAction(title: "No", style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }
    
 
}
