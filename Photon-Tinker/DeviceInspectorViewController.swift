//
//  DeviceInspectorController.swift
//  Particle
//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController, DeviceInspectorChildViewControllerDelegate, Fadeable {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tabBarView: DeviceInspectorTabBarView!
    @IBOutlet weak var moreActionsButton: UIButton!
    @IBOutlet weak var moreInfoView: DeviceInspectorInfoSliderView!


    @IBOutlet var viewsToFade:[UIView]?

    var device: ParticleDevice!
    var isBusy: Bool = false //required by fadeble protocol

    var tabs:[DeviceInspectorChildViewController] = []

    var tinkerVC: DeviceInspectorTinkerViewController!
    var functionsVC: DeviceInspectorFunctionsViewController!
    var variablesVC: DeviceInspectorVariablesViewController!
    var eventsVC: DeviceInspectorEventsViewController!

    override func viewDidLoad() {
        SEGAnalytics.shared().track("DeviceInspector_Started")

        self.tabBarView.setup(tabNames: ["Events", "Functions", "Variables", "Tinker"])


        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.deviceNameLabel.text = self.device.getName()
        self.moreActionsButton.isHidden = !device.is3rdGen()

        self.selectTab(selectedTabIdx: self.tabBarView.selectedIdx, instant: true)
        self.moreInfoView.setup(self.device)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveParticleDeviceSystemNotification), name: Notification.Name.ParticleDeviceSystemEvent, object: nil)

        self.showTutorial()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func didReceiveParticleDeviceSystemNotification(notification: Notification) {
        if let userInfo = notification.userInfo, let device = userInfo["device"] as? ParticleDevice, device.id == self.device.id, let event = userInfo["event"] as? ParticleDeviceSystemEvent {
            if (event == ParticleDeviceSystemEvent.appHashUpdated) {
                self.resetUserAppData()
                self.reloadDeviceData()
            }

            if event == ParticleDeviceSystemEvent.wentOffline || event == ParticleDeviceSystemEvent.cameOnline {
                self.reloadDeviceData()
            }

            if (event == ParticleDeviceSystemEvent.flashStarted) {
                self.updateTab()
            }

            if event == ParticleDeviceSystemEvent.flashSucceeded || event == ParticleDeviceSystemEvent.flashFailed {
                self.reloadDeviceData()

                if (event == ParticleDeviceSystemEvent.flashFailed) {
                    RMessage.showNotification(withTitle: "Flashing error", subtitle: "Error flashing device", type: .error, customTypeName: nil, callback: nil)
                }
            }


        }
    }

    func resetUserAppData() {
        DispatchQueue.main.async {
            for tab in self.tabs {
                tab.resetUserAppData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DeviceInspectorVariablesViewController {
            vc.setup(device: device)
            vc.delegate = self
            self.variablesVC = vc
        } else if let vc = segue.destination as? DeviceInspectorFunctionsViewController {
            vc.setup(device: device)
            vc.delegate = self
            self.functionsVC = vc
        } else if let vc = segue.destination as? DeviceInspectorEventsViewController {
            vc.setup(device: device)
            vc.delegate = self
            self.eventsVC = vc
        } else if let vc = segue.destination as? DeviceInspectorTinkerViewController {
            vc.setup(device: device)
            vc.delegate = self
            self.tinkerVC = vc
        }
    }



    func setup(device: ParticleDevice) {
        self.device = device
    }

    func reloadDeviceData() {
        if (!self.isBusy) {
            DispatchQueue.main.async {
                self.fade()
            }
        }

        self.device.refresh({[weak self] (err: Error?) in
            SEGAnalytics.shared().track("DeviceInspector_RefreshedData")

            if let self = self {
                DispatchQueue.main.async {
                    self.tabs[self.tabBarView.selectedIdx].update()

                    if (err == nil) {
                        self.deviceNameLabel.text = self.device.getName()
                    }

                    self.resume(animated: true)
                }
            }
        })
    }

    func updateTab() {
        DispatchQueue.main.async {
            self.tabs[self.tabBarView.selectedIdx].update()
        }
    }



    private func selectTab(selectedTabIdx: Int, instant: Bool = false) {
        if (tabs.isEmpty) {
            tabs = [eventsVC!, functionsVC!, variablesVC!, tinkerVC!]
        }

        tabs[selectedTabIdx].view.superview!.isHidden = false
        tabs[selectedTabIdx].view.superview!.alpha = 0
        self.view.insertSubview(tabs[selectedTabIdx].view.superview!, belowSubview: self.moreInfoView)
        tabs[selectedTabIdx].update()
        //only show child tutorial if tutorial for this VC was already shown
        if !ParticleUtils.shouldDisplayTutorialForViewController(self) {
            tabs[selectedTabIdx].showTutorial()
        }

        if (!instant) {
            UIView.animate(withDuration: 0.25,
                    animations: { () -> Void in
                        self.tabs[selectedTabIdx].view.superview!.alpha = 1
                    },
                    completion: { success in
                        self.hideOtherTabs()
                    })
        } else {
            self.tabs[selectedTabIdx].view.superview!.alpha = 1
            self.hideOtherTabs()
        }
    }

    private func hideOtherTabs() {
        for i in 0 ..< tabs.count {
            if (i != self.tabBarView.selectedIdx) {
                tabs[i].view.superview!.isHidden = true
            }
        }
    }

    func childViewDidRequestDataRefresh(_ childView: DeviceInspectorChildViewController) {
        self.reloadDeviceData()
    }

    func fade(animated: Bool = true) {
        if (self.tabs[self.tabBarView.selectedIdx].isRefreshing) {
            self.fadeContent(animated: animated, showSpinner: false)
        } else {
            self.fadeContent(animated: animated, showSpinner: true)
        }

        self.view.bringSubview(toFront: self.topBarView)
        self.moreActionsButton.isEnabled = false
    }

    func resume(animated: Bool) {
        self.unfadeContent(animated: animated)

        self.moreActionsButton.isEnabled = true
    }



    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if (self.device.is3rdGen()) {
            let vc = MeshSetupControlPanelUIManager.loadedViewController()
            vc.setDevice(self.device)
            self.present(vc, animated: true)
        } else {
            fatalError("not implemented")
        }
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func tabChanged(_ sender: DeviceInspectorTabBarView) {
        self.view.endEditing(true)
        self.selectTab(selectedTabIdx: sender.selectedIdx)
    }

    let tutorials = [
        ("Welcome to Device Inspector", "See advanced information on your device."),
        ("Modes", "Device inspector has 4 views:\n\nEvents - view a real-time searchable list of published events.\n\nFunctions - interact with your device's functions.\n\nVariables - interact with your device's variables.\n\nTinker - control pin behavior for your device"),
        ("Additional actions", "Tap the Control Panel button to access advanced actions.")
    ]

    func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                //3
                var tutorial3 = YCTutorialBox(headline: self.tutorials[2].0, withHelpText: self.tutorials[2].1) {
                    self.selectTab(selectedTabIdx: self.tabBarView.selectedIdx, instant: true)
                }

                //2
                var tutorial2 = YCTutorialBox(headline: self.tutorials[1].0, withHelpText: self.tutorials[1].1) {
                    tutorial3?.showAndFocus(self.moreActionsButton)
                }

                // 1
                var tutorial = YCTutorialBox(headline: self.tutorials[0].0, withHelpText: self.tutorials[0].0) {
                    tutorial2?.showAndFocus(self.tabBarView)
                }
                tutorial?.showAndFocus(self.view)

                ParticleUtils.setTutorialWasDisplayedForViewController(self)
            }
        }
    }
    
}
