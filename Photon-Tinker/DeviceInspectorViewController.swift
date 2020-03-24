//
//  DeviceInspectorController.swift
//  Particle
//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController, DeviceInspectorChildViewControllerDelegate, Fadeable, DeviceInspectorInfoSliderViewDelegate {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tabBarView: DeviceInspectorTabBarView!
    @IBOutlet weak var moreActionsButton: UIButton!

    @IBOutlet weak var infoSliderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoSliderHeightConstraint: NSLayoutConstraint!

    @IBOutlet var viewsToFade:[UIView]?

    var device: ParticleDevice! {
        didSet {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device set: %@", withParameters: getVaList(["\(device)"]))
        }
    }
    var isBusy: Bool = false //required by fadeble protocol

    var tabs:[DeviceInspectorChildViewController] = []

    var tinkerVC: DeviceInspectorTinkerViewController!
    var functionsVC: DeviceInspectorFunctionsViewController!
    var variablesVC: DeviceInspectorVariablesViewController!
    var eventsVC: DeviceInspectorEventsViewController!
    var infoSlider: DeviceInspectorInfoSliderViewController!

    private var initialControlPanelViewController: Gen3SetupControlPanelUIManager?

    override func viewDidLoad() {
        SEGAnalytics.shared().track("DeviceInspector_Started")

        self.tabBarView.setup(tabNames: [TinkerStrings.DeviceInspector.Tab.Events, TinkerStrings.DeviceInspector.Tab.Functions, TinkerStrings.DeviceInspector.Tab.Variables, TinkerStrings.DeviceInspector.Tab.Tinker])


        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.deviceNameLabel.text = self.device.getName()
        self.updateWithoutReload()

        self.selectTab(selectedTabIdx: self.tabBarView.selectedIdx, instant: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveParticleDeviceSystemNotification), name: Notification.Name.ParticleDeviceSystemEvent, object: nil)

        if let cp = self.initialControlPanelViewController {
            self.initialControlPanelViewController = nil
            cp.setCallback(self.controlPanelCompleted)
            self.present(cp, animated: true)
        } else {
            self.showTutorial()
        }
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
                self.updateWithoutReload()
            }

            if event == ParticleDeviceSystemEvent.flashSucceeded || event == ParticleDeviceSystemEvent.flashFailed {
                self.reloadDeviceData()

                if (event == ParticleDeviceSystemEvent.flashFailed) {
                    DispatchQueue.main.async {
                        RMessage.showNotification(withTitle: TinkerStrings.DeviceInspector.Error.FlashingDeviceError.Title, subtitle: TinkerStrings.DeviceInspector.Error.FlashingDeviceError.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                    }
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
        } else if let vc = segue.destination as? DeviceInspectorInfoSliderViewController {
            vc.setup(device, yConstraint: self.infoSliderYConstraint, heightConstraint: self.infoSliderHeightConstraint)
            self.infoSlider = vc
            self.infoSlider.delegate = self
        }
    }



    func setup(device: ParticleDevice, controlPanelViewController: Gen3SetupControlPanelUIManager? = nil) {
        self.device = device
        self.initialControlPanelViewController = controlPanelViewController
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
                    self.infoSlider.update()
                    self.tabs[self.tabBarView.selectedIdx].update()

                    if (err == nil) {
                        self.deviceNameLabel.text = self.device.getName()
                    }

                    self.resume(animated: true)
                }
            }
        })
    }

    func updateWithoutReload() {
        DispatchQueue.main.async {
            self.deviceNameLabel.text = self.device.getName()
            self.tabs[self.tabBarView.selectedIdx].update()
            self.infoSlider.update()
        }
    }


    private func selectTab(selectedTabIdx: Int, instant: Bool = false) {
        if (tabs.isEmpty) {
            tabs = [eventsVC!, functionsVC!, variablesVC!, tinkerVC!]
        }

        tabs[selectedTabIdx].view.superview!.isHidden = false
        tabs[selectedTabIdx].view.superview!.alpha = 0
        self.view.insertSubview(tabs[selectedTabIdx].view.superview!, belowSubview: self.infoSlider.view.superview!)
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

        self.view.bringSubviewToFront(self.topBarView)
        self.view.bringSubviewToFront(self.infoSlider.view.superview!)
        self.moreActionsButton.isEnabled = false
    }

    func resume(animated: Bool) {
        self.unfadeContent(animated: animated)

        self.moreActionsButton.isEnabled = true
    }



    @IBAction func actionButtonTapped(_ sender: UIButton) {
        let vc = Gen3SetupControlPanelUIManager.loadedViewController()
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "action tapped: %@", withParameters: getVaList(["\(device)"]))
        vc.setDevice(self.device)
        vc.setCallback(self.controlPanelCompleted)
        self.present(vc, animated: true)
    }

    func controlPanelCompleted(result: Gen3SetupFlowResult, data: [AnyObject]?) {
        if result == .unclaimed {
            (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-2] as! DeviceListViewController).refreshData()
            _ = self.navigationController?.popViewController(animated: false)
        }
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func tabChanged(_ sender: DeviceInspectorTabBarView) {
        self.view.endEditing(true)
        self.selectTab(selectedTabIdx: sender.selectedIdx)
    }

    func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                //3
                var tutorial3 = YCTutorialBox(headline: TinkerStrings.DeviceInspector.Tutorial.Tutorial3.Title, withHelpText: TinkerStrings.DeviceInspector.Tutorial.Tutorial3.Message) {
                    self.selectTab(selectedTabIdx: self.tabBarView.selectedIdx, instant: true)
                }

                //2
                var tutorial2 = YCTutorialBox(headline: TinkerStrings.DeviceInspector.Tutorial.Tutorial2.Title, withHelpText: TinkerStrings.DeviceInspector.Tutorial.Tutorial2.Message) {
                    tutorial3?.showAndFocus(self.moreActionsButton)
                }

                // 1
                var tutorial = YCTutorialBox(headline: TinkerStrings.DeviceInspector.Tutorial.Tutorial1.Title, withHelpText: TinkerStrings.DeviceInspector.Tutorial.Tutorial1.Message) {
                    tutorial2?.showAndFocus(self.tabBarView)
                }
                tutorial?.showAndFocus(self.view)

                ParticleUtils.setTutorialWasDisplayedForViewController(self)
            }
        }
    }

    func infoSliderDidUpdateDevice() {
        self.updateWithoutReload()
    }

    func infoSliderDidExpand() {
        if let ipr = self.navigationController?.interactivePopGestureRecognizer?.delegate as? InteractivePopGestureRecognizerDelegateHelper {
            ipr.isEnabled = false
        }
    }

    func infoSliderDidCollapse() {
        if let ipr = self.navigationController?.interactivePopGestureRecognizer?.delegate as? InteractivePopGestureRecognizerDelegateHelper {
            ipr.isEnabled = true
        }
    }
}
