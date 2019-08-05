//
//  DeviceInspectorEventsViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 particle. All rights reserved.
//



class DeviceInspectorEventsViewController: DeviceInspectorChildViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, DeviceEventTableViewCellDelegate {
    @IBOutlet weak var eventFilterSearchBar: UISearchBar!
    @IBOutlet weak var clearEventsButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet var noEventsView: UIView!

    var events: [ParticleEvent] = []
    var filteredEvents: [ParticleEvent] = []
    var filterText: String = ""

    var subscribeId: Any?
    var paused: Bool = false
    var filtering: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        addRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        subscribeToDeviceEvents()
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromDeviceEvents()
    }

    override func update() {
        super.update()

        self.tableView.reloadData()

        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

        self.evalNoEventsViewVisibility()
    }

    func subscribeToDeviceEvents() {
        self.subscribeId = ParticleCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: nil, deviceID: self.device.id, handler: {[weak self] (event:ParticleEvent?, error:Error?) in
            if let _ = error {
                print ("could not subscribe to events to show in events inspector...")
            } else {
                
                DispatchQueue.main.async(execute: {
                    if let self = self {
                        if let e = event {
                            // insert new event to datasource
                            self.events.insert(e, at: 0)
                            if self.filtering {
                                self.filterEvents()
                                self.tableView.reloadData()
                            } else {
                                if !self.view.isHidden {
                                    self.tableView.beginUpdates()
                                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                                    self.tableView.endUpdates()
                                } else {
                                    self.tableView.reloadData()
                                }
                            }

                            self.evalNoEventsViewVisibility()
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


    let tutorials = [
        ("Device Events", "This is a searchable log of the events your device published to the cloud. Tap the blue clipboard button to copy event payload to your clipboard."),
        ("Search events", "Tap filter text field and type text to filter the events list and show only events containing the search text. Filtering is performed on event name and data."),
        ("Play and pause", "Tap play/pause button to pause the events stream momentarily. Events published while stream is paused will not be added to the list.")
    ]

    override func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                //3
                var tutorial3 = YCTutorialBox(headline: self.tutorials[2].0, withHelpText: self.tutorials[2].1)

                //2
                var tutorial2 = YCTutorialBox(headline: self.tutorials[1].0, withHelpText: self.tutorials[1].1) {
                    tutorial3?.showAndFocus(self.eventFilterSearchBar.superview)
                }

                // 1
                var tutorial = YCTutorialBox(headline: self.tutorials[0].0, withHelpText: self.tutorials[0].1) {
                    tutorial2?.showAndFocus(self.eventFilterSearchBar)
                }
                tutorial?.showAndFocus(self.view)

                ParticleUtils.setTutorialWasDisplayedForViewController(self)
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
        self.tableView.reloadData()
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
        }
        
        self.filterText = searchText.lowercased()
        self.filterEvents()

        SEGAnalytics.shared().track("DeviceInspector_EventFilterTyping")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

    func filterEvents() {
        if self.filtering {
            self.filteredEvents = self.events.filter({$0.event.lowercased().contains(self.filterText) || $0.data!.lowercased().contains(self.filterText)}) // filter for both name and data
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtering {
            return self.filteredEvents.count
        } else {
            return self.events.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceEventTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "eventCell") as! DeviceEventTableViewCell

        if filtering {
            cell.setup(self.filteredEvents[(indexPath as NSIndexPath).row])
        } else {
            cell.setup(self.events[(indexPath as NSIndexPath).row])
        }

        cell.delegate = self

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
                self.events = []
                self.filteredEvents = []
                self.tableView.reloadData()
                self.evalNoEventsViewVisibility()
            }
            SEGAnalytics.shared().track("DeviceInspector_EventsCleared")
        })

        alert.addAction(UIAlertAction(title: "No", style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

    func evalNoEventsViewVisibility() {
        self.tableView.tableHeaderView = nil
        self.noEventsView.removeFromSuperview()
        self.tableView.tableHeaderView = (self.events.count > 0) ? nil : self.noEventsView

        self.adjustTableViewHeaderViewConstraints()
    }

    override func adjustTableViewHeaderViewConstraints() {
        if (self.tableView.tableHeaderView == nil) {
            return
        }

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.75, constant: 0),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.heightAnchor, multiplier: 0.75, constant: 0),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.widthAnchor)
            ])
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func tappedOnCopyButton(_ sender: DeviceEventTableViewCell, event: ParticleEvent) {
        UIPasteboard.general.string = event.description
        RMessage.showNotification(withTitle: "Copied", subtitle: "Event payload was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
        SEGAnalytics.shared().track("DeviceInspector_EventCopied")
    }

    func tappedOnPayloadButton(_ sender: DeviceEventTableViewCell, event: ParticleEvent) {
        let alert = UIAlertController(title: event.event, message: "\(event.data ?? "")\r\n\r\n\(event.time.eventTimeFormattedString())", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Copy data to clipboard", style: .default) { [weak self] action in
            UIPasteboard.general.string = event.data ?? ""
            RMessage.showNotification(withTitle: "Copied", subtitle: "Event data was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_EventDataCopied")
        })

        alert.addAction(UIAlertAction(title: "Copy event to clipboard", style: .default) { [weak self] action in
            UIPasteboard.general.string = event.description
            RMessage.showNotification(withTitle: "Copied", subtitle: "Event payload was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_EventPayloadCopied")
        })

        alert.addAction(UIAlertAction(title: "Close", style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

}
