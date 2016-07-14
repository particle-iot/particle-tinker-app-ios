//
//  DeviceInspectorController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController, UITextFieldDelegate {
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        // heading
        view.endEditing(true)
        let dialog = ZAlertView(title: "More Actions", message: nil, alertType: .MultipleChoice)
        

        
        dialog.addButton("Reflash Tinker", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
            self.reflashTinker()
            
        }
        
        
        dialog.addButton("Rename device", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
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
            self.renameDialog!.addTextField("name", placeHolder: self.device!.name!)
            let tf = self.renameDialog!.getTextFieldWithIdentifier("name")
            tf?.text = self.device?.name
            tf?.delegate = self
            tf?.tag = 100

            self.renameDialog!.show()
            tf?.becomeFirstResponder()
        }
        
       
        
        dialog.addButton("Refresh data", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            self.device?.refresh({[unowned self] (err: NSError?) in
                
                
                // test what happens when device goes offline and refresh is triggered
                if (err == nil) {
                    print("data updated")
                    
                    self.viewWillAppear(false)
                    
                    if let info = self.infoVC {
                        info.device = self.device
                        info.updateDeviceInfoDisplay()
                    }
                    
                    if let data = self.dataVC {
                        data.device = self.device
                        data.refreshVariableList()
                    }
                    
                    if let events = self.eventsVC {
                        events.unsubscribeFromDeviceEvents()
                        events.device = self.device
                        if !events.paused {
                            events.subscribeToDeviceEvents()
                        }
                        
                    }
                }
                })
        }
        
        
        dialog.addButton("Signal for 10sec", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            self.device?.signal(true, completion: nil)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.device?.signal(false, completion: nil)
            }
            
            
        }
        
        dialog.addButton("Support/Documentation", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleEmeraldColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
            self.popDocumentationViewController()
        }
        

        dialog.addButton("Cancel", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.whiteColor()) { (dialog : ZAlertView) in
            dialog.dismiss()
        }
        
        
        dialog.show()
        
        
        
        
        
    }
    
    @IBOutlet weak var deviceOnlineIndicatorImageView: UIImageView!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    var renameDialog : ZAlertView?
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 100 {
            self.renameDevice(textField.text)
            renameDialog?.dismiss()
            
        }
        
        return true
    }
    

    func renameDevice(newName : String?) {
        self.device?.rename(newName!, completion: {[unowned self] (error : NSError?) in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.deviceNameLabel.text = newName!.stringByReplacingOccurrencesOfString(" ", withString: "_")
                    self.deviceNameLabel.setNeedsLayout()
                }
                
            }
        })
    }
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        
        
        
//        [UIView transitionWithView:self.view duration:0.3 options: UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
//            [self.view addSubview:blurView];
//            } completion:nil];
//        
        view.endEditing(true)
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
            self.deviceInfoContainerView.alpha = (sender.selectedSegmentIndex == 0 ? 1.0 : 0.0)
            self.deviceDataContainerView.alpha = (sender.selectedSegmentIndex == 1 ? 1.0 : 0.0)
            self.deviceEventsContainerView.alpha = (sender.selectedSegmentIndex == 2 ? 1.0 : 0.0)
            
                        
        }) { (finished: Bool) in
            
            var delayTime = dispatch_time(DISPATCH_TIME_NOW,0)
            if !finished {
                delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            }
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.deviceInfoContainerView.hidden = (sender.selectedSegmentIndex == 0 ? false : true)
                self.deviceDataContainerView.hidden = (sender.selectedSegmentIndex == 1 ? false : true)
                self.deviceEventsContainerView.hidden = (sender.selectedSegmentIndex == 2 ? false : true)
            }
            
        }
        
        if (sender.selectedSegmentIndex == 2) // events
        {
            self.eventsVC!.viewDidAppearFirstTime()
        }
 
        
    }
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceEventsContainerView: UIView!
    @IBOutlet weak var deviceDataContainerView: UIView!
    @IBOutlet weak var deviceInfoContainerView: UIView!
    
    var device : SparkDevice?
    
//    var frameView: UIView!
    
    override func viewDidLoad() {

        self.deviceInfoContainerView.hidden = false
        self.deviceDataContainerView.hidden = true
        self.deviceEventsContainerView.hidden = true

       
        let font = UIFont(name: "Gotham-book", size: 15.0)
        
        let attrib = [NSFontAttributeName : font!]
        
        self.modeSegmentedControl.setTitleTextAttributes(attrib, forState: .Normal)
        
//        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        
        

    }
    
    var infoVC : DeviceInspectorInfoViewController?
    var dataVC : DeviceInspectorDataViewController?
    var eventsVC : DeviceInspectorEventsViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // if its either the info data or events VC then set the device to what we are inspecting
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            if let vc = segue.destinationViewController as? DeviceInspectorChildViewController {
                vc.device = self.device
                
                if let i = vc as? DeviceInspectorInfoViewController {
                    self.infoVC = i
                }
                
                if let d = vc as? DeviceInspectorDataViewController {
                    self.dataVC = d
                }
                
                if let e = vc as? DeviceInspectorEventsViewController {
                    self.eventsVC = e
                }
                
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.deviceNameLabel.text = self.device?.name
        ParticleUtils.animateOnlineIndicatorImageView(self.deviceOnlineIndicatorImageView, online: self.device!.connected, flashing: self.device!.isFlashing)
    }
    
    
    
    // 2
    func reflashTinker() {

        if !self.device!.connected {
            TSMessage.showNotificationWithTitle("Device offline", subtitle: "Device must be online to be flashed", type: .Error)
            return
        }
        
        func flashTinkerBinary(binaryFilename : String?)
        {
            let bundle = NSBundle.mainBundle()
            let path = bundle.pathForResource(binaryFilename, ofType: "bin")
            let binary = NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
            let filesDict = ["tinker.bin" : binary!]
            self.device!.flashFiles(filesDict, completion: { (error:NSError?) -> Void in
                if let e=error
                {
                    TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                }
                else
                {
                    TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                }
            })
        }
        
        
        switch (self.device!.type)
        {
        case .Core:
            //                                        Mixpanel.sharedInstance().track("Tinker: Reflash Tinker",
            Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Core"])
            
            self.device!.flashKnownApp("tinker", completion: { (error:NSError?) -> Void in
                if let e=error
                {
                    TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                }
                else
                {
                    TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                }
            })
            
        case .Photon:
            Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Photon"])
            flashTinkerBinary("photon-tinker")
            
        case .Electron:
            Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Electron"])
            
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
            TSMessage.showNotificationWithTitle("Reflash Tinker", subtitle: "Cannot flash Tinker to a non-Particle device", type: .Warning)
            
            
        }
        
    }
    
    
    func popDocumentationViewController() {

        self.performSegueWithIdentifier("help", sender: self)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("help")
//        self.navigationController?.pushViewController(vc, animated: true)
    }


}