//
//  DeviceInspectorEventsViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright (c) 2019 Particle. All rights reserved.
//



class DeviceInspectorEventsViewController: DeviceInspectorChildViewController, SearchBarViewDelegate, UITableViewDelegate, UITableViewDataSource, DeviceEventTableViewCellDelegate {
    @IBOutlet weak var searchBar: SearchBarView!
    @IBOutlet weak var clearEventsButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!

    @IBOutlet var noEventsView: UIView!

    var events: [ParticleEvent] = []
    var filteredEvents: [ParticleEvent] = []
    var filterText: String = ""

    var subscribeId: Any?
    var paused: Bool = false
    var filtering: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = ParticleStyle.ButtonColor
        self.clearEventsButton.tintColor = ParticleStyle.ButtonColor
        self.playPauseButton.tintColor = ParticleStyle.ButtonColor
        self.noEventsView.removeFromSuperview()

        addRefreshControl()
        setupSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        subscribeToDeviceEvents()
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromDeviceEvents()
    }

    private func setupSearch() {
        searchBar.inputText.placeholder = TinkerStrings.Events.SearchPlaceholder
        searchBar.delegate = self
    }

    //MARK: Search bar delegate
    func searchBarTextDidChange(searchBar: SearchBarView, text: String?) {
        if let text = text, text.count > 0 {
            self.filtering = true
            self.filterText = text
            self.filterEvents()
            SEGAnalytics.shared().track("DeviceInspector_EventFilterTyping")

        } else {
            self.filtering = false
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func searchBarDidBeginEditing(searchBar: SearchBarView) {

    }

    func searchBarDidEndEditing(searchBar: SearchBarView) {

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

    override func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                //3
                var tutorial3 = YCTutorialBox(headline: TinkerStrings.Events.Tutorial.Tutorial3.Title, withHelpText: TinkerStrings.Events.Tutorial.Tutorial3.Message)

                //2
                var tutorial2 = YCTutorialBox(headline: TinkerStrings.Events.Tutorial.Tutorial2.Title, withHelpText: TinkerStrings.Events.Tutorial.Tutorial2.Message) {
                    tutorial3?.showAndFocus(self.searchBar.superview)
                }

                // 1
                var tutorial = YCTutorialBox(headline: TinkerStrings.Events.Tutorial.Tutorial1.Title, withHelpText: TinkerStrings.Events.Tutorial.Tutorial1.Message) {
                    tutorial2?.showAndFocus(self.searchBar)
                }
                tutorial?.showAndFocus(self.view)

                ParticleUtils.setTutorialWasDisplayedForViewController(self)
            }
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
            playPauseButton.setImage(UIImage(named: "IconPause"), for: .normal)
            subscribeToDeviceEvents()
        } else {
            paused = true
            SEGAnalytics.shared().track("DeviceInspector_EventStreamPause")
            playPauseButton.setImage(UIImage(named: "IconPlay"), for: .normal)
            unsubscribeFromDeviceEvents()
        }
    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: TinkerStrings.Events.Prompt.ClearAllEvents.Title, message: TinkerStrings.Events.Prompt.ClearAllEvents.Message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Yes, style: .default) { [weak self] action in
            if let self = self {
                self.events = []
                self.filteredEvents = []
                self.tableView.reloadData()
                self.evalNoEventsViewVisibility()
            }
            SEGAnalytics.shared().track("DeviceInspector_EventsCleared")
        })

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.No, style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

    func evalNoEventsViewVisibility() {
        self.tableView.tableHeaderView = nil
        self.noEventsView.removeFromSuperview()
        self.tableView.tableHeaderView = (self.events.count > 0) ? nil : self.noEventsView

        self.adjustTableViewHeaderViewConstraints()
    }

    func tappedOnCopyButton(_ sender: DeviceEventTableViewCell, event: ParticleEvent) {
        UIPasteboard.general.string = event.description
        RMessage.showNotification(withTitle: TinkerStrings.Events.Prompt.EventCopied.Title, subtitle: TinkerStrings.Events.Prompt.EventCopied.Message, type: .success, customTypeName: nil, callback: nil)
        SEGAnalytics.shared().track("DeviceInspector_EventCopied")
    }

    func tappedOnPayloadButton(_ sender: DeviceEventTableViewCell, event: ParticleEvent) {
        let alert = UIAlertController(title: event.event, message: "\(event.data ?? "")\r\n\r\n\(event.time.eventTimeFormattedString())", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.CopyDataToClipboard, style: .default) { [weak self] action in
            UIPasteboard.general.string = event.data ?? ""
            RMessage.showNotification(withTitle: TinkerStrings.Events.Prompt.DataCopied.Title, subtitle: TinkerStrings.Events.Prompt.DataCopied.Message, type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_EventDataCopied")
        })

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.CopyEventToClipboard, style: .default) { [weak self] action in
            UIPasteboard.general.string = event.description
            RMessage.showNotification(withTitle: TinkerStrings.Events.Prompt.EventCopied.Title, subtitle: TinkerStrings.Events.Prompt.EventCopied.Message, type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_EventPayloadCopied")
        })

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Close, style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

}
