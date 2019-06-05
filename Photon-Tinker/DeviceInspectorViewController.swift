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
    }

    override func viewWillAppear(_ animated: Bool) {
        self.deviceNameLabel.text = self.device.name ?? "<no name>"
        self.moreActionsButton.isHidden = !device.is3rdGen()

        self.selectTab(selectedTabIdx: self.tabBarView.selectedIdx, instant: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveParticleDeviceSystemNotification), name: Notification.Name.ParticleDeviceSystemEvent, object: nil)
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
                        self.deviceNameLabel.text = self.device.name ?? "<no name>"
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
        self.view.bringSubview(toFront: tabs[selectedTabIdx].view.superview!)
        tabs[selectedTabIdx].update()
        tabs[selectedTabIdx].showTutorial()

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







//
//
//
//    func showTutorial() {
//
//        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
//
//            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            DispatchQueue.main.asyncAfter(deadline: delayTime) {
//
//                if self.navigationController?.visibleViewController == self {
//                    // viewController is visible
//
//                    // 3
////                    var tutorial = YCTutorialBox(headline: "Additional actions", withHelpText: "Tap the three dots button for more actions such as reflashing the Tinker firmware, force refreshing the device info/data, signal the device (LED shouting rainbows), changing device name and easily accessing Particle documentation and support portal.")
////                    tutorial.showAndFocusView(self.moreActionsButton)
////
////                    // 2
////                    tutorial = YCTutorialBox(headline: "Modes", withHelpText: "Device inspector has 3 modes - tap 'Info' to see your device network parameters, tap 'data' to interact with your device exposed functions and variables, tap 'events' to view a searchable list of the device published events.")
////
//
//
//                    // 1
//                    let tutorial = YCTutorialBox(headline: "Welcome to Device Inspector", withHelpText: "See advanced information on your device. Tap the blue clipboard icon to copy device ID or ICCID field to the clipboard.", withCompletionBlock: {
//                        // 2
//                        let tutorial = YCTutorialBox(headline: "Modes", withHelpText: "Device inspector has 3 modes:\n\nInfo - see your device network parameters.\n\nData - interact with your device's functions and variables.\n\nEvents - view a real-time searchable list of published events.", withCompletionBlock:  {
//                            let tutorial = YCTutorialBox(headline: "Additional actions", withHelpText: "Tap the additional actions button for reflashing Tinker firmware, force refreshing the device info and data, signal (identify a device by its LED color-cycling), renaming a device and easily accessing Particle documentation and support portal.")
//
//                            let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                            DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                                tutorial?.showAndFocus(self.moreActionsButton)
//                            }
//
//
//                        })
//                        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//
//                        }
//
//                    })
//
//                    tutorial?.showAndFocus(self.infoContainerView)
//
//                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
//                }
//
//            }
//        }
//    }
    
    
    
}
