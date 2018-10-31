//
//  DeviceInspectorController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/16.
//  Copyright © 2016 particle. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController, UITextFieldDelegate, ParticleDeviceDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        // heading
        view.endEditing(true)
        let dialog = ZAlertView(title: "More Actions", message: nil, alertType: .multipleChoice)
        

        
        dialog.addButton("Reflash Tinker", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
            self.reflashTinker()
            
        }
        
        
        dialog.addButton("Rename device", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismissWithDuration(0.01)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { () -> Void in
                self.renameDialog = ZAlertView(title: "Rename device", message: nil, isOkButtonLeft: true, okButtonText: "Rename", cancelButtonText: "Cancel",
                        okButtonHandler: { [unowned self] alertView in

                            let tf = alertView.getTextFieldWithIdentifier("name")
                            self.renameDevice(tf!.text)
                            alertView.dismiss()
                        },
                        cancelButtonHandler: { alertView in
                            alertView.dismiss()
                        }
                )
                self.renameDialog!.addTextField("name", placeHolder: self.device!.name ?? "")
                let tf = self.renameDialog!.getTextFieldWithIdentifier("name")
                tf?.text = self.device?.name ?? self.getRandomDeviceName()
                tf?.delegate = self
                tf?.tag = 100

                self.renameDialog!.show()
                tf?.becomeFirstResponder()
            }
        }
        
       
        
        dialog.addButton("Refresh data", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            self.refreshData()
        }
        
        
        dialog.addButton("Signal for 10sec", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            self.device?.signal(true, completion: nil)
            let delayTime = DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.device?.signal(false, completion: nil)
            }
            
            
        }
        
        dialog.addButton("Support/Documentation", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleEmeraldColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
            self.popDocumentationViewController()
        }
        

        dialog.addButton("Cancel", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.white) { (dialog : ZAlertView) in
            dialog.dismiss()
        }
        
        
        dialog.show()
    }

    //todo: move this to setup lib?
    private let randomNames = ["aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "maker", "splendid", "sparkling", "dentist", "doctor", "green", "easter", "ferret", "gerbil", "hacker", "hamster", "wizard", "hobbit", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "burrito", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie"]
    func getRandomDeviceName() -> String {
        return "\(randomNames.randomElement()!)_\(randomNames.randomElement()!)"
    }

    
    @IBOutlet weak var deviceOnlineIndicatorImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    var renameDialog : ZAlertView?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 100 {
            self.renameDevice(textField.text)
            renameDialog?.dismiss()
            
        }
        
        return true
    }
    

    func renameDevice(_ newName : String?) {
        self.device?.rename(newName!, completion: {[weak self] (error : Error?) in
            
            if error == nil {
                if let s = self {
                    DispatchQueue.main.async {
                        s.deviceNameLabel.text = newName!.replacingOccurrences(of: " ", with: "_")
                        s.deviceNameLabel.setNeedsLayout()
                    }
                }
                
            }
        })
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        
        
        
//        [UIView transitionWithView:self.view duration:0.3 options: UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
//            [self.view addSubview:blurView];
//            } completion:nil];
//        
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.infoContainerView.alpha = (sender.selectedSegmentIndex == 0 ? 1.0 : 0.0)
            self.deviceDataContainerView.alpha = (sender.selectedSegmentIndex == 1 ? 1.0 : 0.0)
            self.deviceEventsContainerView.alpha = (sender.selectedSegmentIndex == 2 ? 1.0 : 0.0)
            
                        
        }) { (finished: Bool) in
            
            var delayTime = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
            if !finished {
                delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            }
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.infoVC!.view.isHidden = (sender.selectedSegmentIndex == 0 ? false : true)
                self.dataVC!.view.isHidden = (sender.selectedSegmentIndex == 1 ? false : true)
                self.eventsVC!.view.isHidden = (sender.selectedSegmentIndex == 2 ? false : true)
            }
            
        }
        
        // since the embed segue already triggers the VC lifecycle functions - this is an override to re-call them on change of segmented view to trigger relevant inits or tutorial boxes
        
        if (sender.selectedSegmentIndex == 0) // info
        {
            self.infoVC!.showTutorial()
            SEGAnalytics.shared().track("Device Inspector: info view")
        }
        
        if (sender.selectedSegmentIndex == 1) // functions and variables
        {
            self.dataVC!.refreshVariableList()
            self.dataVC!.showTutorial()
            self.dataVC!.readAllVariablesOnce()
            SEGAnalytics.shared().track("Device Inspector: data view")
        }
        
        if (sender.selectedSegmentIndex == 2) // events
        {
            self.eventsVC!.showTutorial()
            SEGAnalytics.shared().track("Device Inspector: events view")
        }
 
        
    }
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceEventsContainerView: UIView!
    @IBOutlet weak var deviceDataContainerView: UIView!
    @IBOutlet weak var deviceInfoContainerView: UIView!
    
    @objc var device : ParticleDevice?
    
//    var frameView: UIView!
    
    override func viewDidLoad() {

        SEGAnalytics.shared().track("Device Inspector: started")
       
        let font = UIFont(name: "Gotham-book", size: 15.0)
        
        let attrib = [NSAttributedStringKey.font : font!]
        
        self.modeSegmentedControl.setTitleTextAttributes(attrib, for: UIControlState())
        
        self.infoContainerView.alpha = 1
        
        if let ivc = self.infoVC {
            ivc.view.isHidden = false
        }
        self.view.bringSubview(toFront: infoContainerView)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        showTutorial()
    }
    
    var infoVC : DeviceInspectorInfoViewController?
    var dataVC : DeviceInspectorDataViewController?
    var eventsVC : DeviceInspectorEventsViewController?
    
    
    // happens right as Device Inspector is displayed as all VCs are in an embed segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if its either the info data or events VC then set the device to what we are inspecting
        
        DispatchQueue.global().async {
            // do some task
            if let vc = segue.destination as? DeviceInspectorChildViewController {
                vc.device = self.device
                
                if let i = vc as? DeviceInspectorInfoViewController {
                    self.infoVC = i
                    DispatchQueue.main.async {
                        i.view.isHidden = false
                    }
                }
                
                if let d = vc as? DeviceInspectorDataViewController {
                    self.dataVC = d
                    DispatchQueue.main.async {
                        d.view.isHidden = true
                    }
                }
                
                if let e = vc as? DeviceInspectorEventsViewController {
                    self.eventsVC = e
                    DispatchQueue.main.async {
                        e.view.isHidden = true
                    }
                }
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.deviceNameLabel.text = self.device?.name ?? "<no name>"
        self.device!.delegate = self
        ParticleUtils.animateOnlineIndicatorImageView(self.deviceOnlineIndicatorImageView, online: self.device!.connected, flashing: self.device!.isFlashing)
    }
    
    var flashedTinker : Bool = false
    
    func particleDevice(_ device: ParticleDevice, didReceive event: ParticleDeviceSystemEvent) {
        ParticleUtils.animateOnlineIndicatorImageView(self.deviceOnlineIndicatorImageView, online: self.device!.connected, flashing: self.device!.isFlashing)
        if self.flashedTinker && event == .flashSucceeded {
            
            SEGAnalytics.shared().track("Device Inspector: reflash Tinker success")
            DispatchQueue.main.async {
                RMessage.showNotification(withTitle: "Flashing successful", subtitle: "Your device has been flashed with Tinker firmware successfully", type: .success, customTypeName: nil, callback: nil)
            }
            self.flashedTinker = false
//            self.refreshData()
            
        }
        
        self.refreshData()
    }
    
    
    
    
    func refreshData() {
        self.device?.refresh({[weak self] (err: Error?) in
            
            SEGAnalytics.shared().track("Device Inspector: refreshed data")
            // test what happens when device goes offline and refresh is triggered
            if (err == nil) {
                
                if let s = self {
                    s.viewWillAppear(false)
                    
                    if let info = s.infoVC {
                        info.device = s.device
                        info.updateDeviceInfoDisplay()
                    }
                    
                    if let data = s.dataVC {
                        data.device = s.device
                        data.refreshVariableList()
                    }
                    
                    if let events = s.eventsVC {
                        events.unsubscribeFromDeviceEvents()
                        events.device = s.device
                        if !events.paused {
                            events.subscribeToDeviceEvents()
                        }
                        
                    }
                }
            }
            })
    }
    
    
    // 2
    func reflashTinker() {

//        if !self.device!.connected {
//            TSMessage.showNotificationWithTitle("Device offline", subtitle: "Device must be online to be flashed", type: .Error)
//            return
//        }
        SEGAnalytics.shared().track("Device Inspector: reflash Tinker start")
        
        func flashTinkerBinary(_ binaryFilename : String?)
        {
            let bundle = Bundle.main
            let path = bundle.path(forResource: binaryFilename, ofType: "bin")
            let binary = try? Data(contentsOf: URL(fileURLWithPath: path!))
            let filesDict = ["tinker.bin" : binary!]
            self.flashedTinker = true
            self.device!.flashFiles(filesDict, completion: { [weak self] (error:Error?) -> Void in
                if let e=error
                {
                    if let s = self {
                        s.flashedTinker = false
                        RMessage.showNotification(withTitle: "Flashing error", subtitle: "Error flashing device. Are you sure it's online? \(e.localizedDescription)", type: .error, customTypeName: nil, callback: nil)
                    }
                    
                }
            })
        }
        
        
        switch (self.device!.type)
        {
        case .core:
            //                                        SEGAnalytics.sharedAnalytics().track("Tinker: Reflash Tinker",
            SEGAnalytics.shared().track("Tinker: Reflash Tinker", properties: ["device":"Core"])
            self.flashedTinker = true
            self.device!.flashKnownApp("tinker", completion: { (error:Error?) -> Void in
                if let e=error
                {
                    RMessage.showNotification(withTitle: "Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .error, customTypeName: nil, callback: nil)
                }
            })
            
        case .photon:
            SEGAnalytics.shared().track("Tinker: Reflash Tinker", properties: ["device":"Photon"])
            flashTinkerBinary("photon-tinker")
            
        case .electron:
            SEGAnalytics.shared().track("Tinker: Reflash Tinker", properties: ["device":"Electron"])
            
            let dialog = ZAlertView(title: "Flashing Electron", message: "Flashing Tinker to Electron via cellular will consume data from your data plan, are you sure you want to continue?", isOkButtonLeft: true, okButtonText: "No", cancelButtonText: "Yes",
                                    okButtonHandler: { alertView in
                                        alertView.dismiss()
                                        
                },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismiss()
                                        flashTinkerBinary("electron-tinker")
                                        
                }
            )
            
            
            
            dialog.show()
            
        default:
            
            
            RMessage.showNotification(withTitle: "Reflash Tinker", subtitle: "Cannot flash Tinker to a non-Particle device", type: .warning, customTypeName: nil, callback: nil)
        }
        
    }
    
    
    func popDocumentationViewController() {

        SEGAnalytics.shared().track("Device Inspector: documentation")
        self.performSegue(withIdentifier: "help", sender: self)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("help")
//        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBOutlet weak var infoContainerView: UIView!
    
    @IBOutlet weak var moreActionsButton: UIButton!
    
    func showTutorial() {
        
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if self.navigationController?.visibleViewController == self {
                    // viewController is visible
                    
                    // 3
//                    var tutorial = YCTutorialBox(headline: "Additional actions", withHelpText: "Tap the three dots button for more actions such as reflashing the Tinker firmware, force refreshing the device info/data, signal the device (LED shouting rainbows), changing device name and easily accessing Particle documentation and support portal.")
//                    tutorial.showAndFocusView(self.moreActionsButton)
//                    
//                    // 2
//                    tutorial = YCTutorialBox(headline: "Modes", withHelpText: "Device inspector has 3 modes - tap 'Info' to see your device network parameters, tap 'data' to interact with your device exposed functions and variables, tap 'events' to view a searchable list of the device published events.")
//                    
//                    tutorial.showAndFocusView(self.modeSegmentedControl)
                    
                    
                    // 1
                    let tutorial = YCTutorialBox(headline: "Welcome to Device Inspector", withHelpText: "See advanced information on your device. Tap the blue clipboard icon to copy device ID or ICCID field to the clipboard.", withCompletionBlock: {
                        // 2
                        let tutorial = YCTutorialBox(headline: "Modes", withHelpText: "Device inspector has 3 modes:\n\nInfo - see your device network parameters.\n\nData - interact with your device's functions and variables.\n\nEvents - view a real-time searchable list of published events.", withCompletionBlock:  {
                            let tutorial = YCTutorialBox(headline: "Additional actions", withHelpText: "Tap the additional actions button for reflashing Tinker firmware, force refreshing the device info and data, signal (identify a device by its LED color-cycling), renaming a device and easily accessing Particle documentation and support portal.")
                            
                            let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                                tutorial?.showAndFocus(self.moreActionsButton)
                            }
                            

                        })
                        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        
                            tutorial?.showAndFocus(self.modeSegmentedControl)
                        }

                    })
                    
                    tutorial?.showAndFocus(self.infoContainerView)
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
                
            }
        }
    }
    
    
    
}
