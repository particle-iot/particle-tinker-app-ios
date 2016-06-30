//
//  DeviceInspectorController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController {
    
    
    var signalling : Bool = false
 
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func actionButtonTapped(sender: UIButton) {
            // heading
            let actionMenu = UIAlertController(title: "Device action", message: nil, preferredStyle: .ActionSheet)
            
            
            // 1
            let refreshAction = UIAlertAction(title: "Refresh data", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.device?.refresh({ (err: NSError?) in
                    
                    // test what happens when device goes offline and refresh is triggered
                    if (err == nil) {
//                        self.updateDeviceInfoDisplay()
                    }
                })
                
            })
//            refreshAction.setValue(UIImage(named: "imgLoop"), forKey: "image")
        
            // 2
            let signalAction = UIAlertAction(title: signalling ? "Stop Signal" : "Signal", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.signalling = !self.signalling
                self.device?.signal(self.signalling, completion: nil)
                
            })
//            signalAction.setValue(UIImage(named: "imgLedSignal"), forKey: "image")
        
            // 3
            let reflashAction = UIAlertAction(title: "Reflash Tinker", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                /// WIP
                self.reflashTinker()
            })
//            reflashAction.setValue(UIImage(named: "imgReflash"), forKey: "image")
        
            
            let editNameAction = UIAlertAction(title: "Edit Name", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                /// WIP
            })
//            editNameAction.setValue(UIImage(named: "imgPencil"), forKey: "image")
        
            let docsAction = UIAlertAction(title: "Support/Documentation", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("help", sender: self);
                
            })
//            docsAction.setValue(UIImage(named: "imgQuestion"), forKey: "image")
        
            
            
            // cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            
            // 4
            actionMenu.addAction(refreshAction)
            actionMenu.addAction(signalAction)
            actionMenu.addAction(reflashAction)
            actionMenu.addAction(editNameAction)
            actionMenu.addAction(docsAction)
            actionMenu.addAction(cancelAction)
            
            // 5
            self.presentViewController(actionMenu, animated: true, completion: nil)
            

    }
    
    @IBOutlet weak var deviceOnlineIndicatorImageView: UIImageView!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        
        
        
//        [UIView transitionWithView:self.view duration:0.3 options: UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
//            [self.view addSubview:blurView];
//            } completion:nil];
//        

        
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
 
        
    }
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceEventsContainerView: UIView!
    @IBOutlet weak var deviceDataContainerView: UIView!
    @IBOutlet weak var deviceInfoContainerView: UIView!
    
    var device : SparkDevice?
    
    
    override func viewDidLoad() {

        self.deviceInfoContainerView.hidden = false
        self.deviceDataContainerView.hidden = true
        self.deviceEventsContainerView.hidden = true

       
        let font = UIFont(name: "Gotham-book", size: 15.0)
        
        let attrib = [NSFontAttributeName : font!]
        
        self.modeSegmentedControl.setTitleTextAttributes(attrib, forState: .Normal)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // if its either the info data or events VC then set the device to what we are inspecting
        if let vc = segue.destinationViewController as? DeviceInspectorChildViewController {
            vc.device = self.device
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.deviceNameLabel.text = self.device?.name
        DeviceUtils.animateOnlineIndicatorImageView(self.deviceOnlineIndicatorImageView, online: self.device!.connected)
    }
    
 
    
    // 2
    func reflashTinker() {
        
        
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
                    //                                                self.deviceIDsBeingFlashed[device.id] = defaultFlashingTime
                    //                                                self.flashingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "flashingTimerFunc:", userInfo: nil, repeats: true)
                    //                        device.isFlashing = true
                    //                        self.deviceIDflashingDict[device.id] = kDefaultCoreFlashingTime
                    //                        self.photonSelectionTableView.reloadData()
                    
                }
            })
            
        case .Photon:
            Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Photon"])
            
            let bundle = NSBundle.mainBundle()
            let path = bundle.pathForResource("photon-tinker", ofType: "bin")
            //                                        var error:NSError?
            if let binary: NSData? = NSData.dataWithContentsOfMappedFile(path!) as? NSData // fix deprecation
            {
                let filesDict = ["tinker.bin" : binary!]
                self.device!.flashFiles(filesDict, completion: { (error:NSError?) -> Void in
                    if let e=error
                    {
                        TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                    }
                    else
                    {
                        TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                        //                            device.isFlashing = true
                        //                            self.deviceIDflashingDict[device.id] = kDefaultPhotonFlashingTime
                        //                            self.photonSelectionTableView.reloadData()
                        
                    }
                })
                
            }
        case .Electron:
            Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Electron"])
            // TODO: support flashing tinker to Electron
            //                                TSMessage.showNotificationWithTitle("Not supported", subtitle: "Operation not supported yet, coming soon.", type: .Warning)
            
            
            // heading
            let areYouSureAlert = UIAlertController(title: "Flashing Tinker to Electron", message: "Flashing Tinker to Electron will consume X KB of data from your data plan, are you sure you want to continue?", preferredStyle: .Alert)
            
            let noAction = UIAlertAction(title: "No", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                // check if this works otherwise put binary
                let bundle = NSBundle.mainBundle()
                let path = bundle.pathForResource("electron-tinker", ofType: "bin")
                //                                        var error:NSError?
                if let binary: NSData? = NSData.dataWithContentsOfMappedFile(path!) as? NSData // fix deprecation
                {
                    let filesDict = ["tinker.bin" : binary!]
                    self.device!.flashFiles(filesDict, completion: { (error:NSError?) -> Void in
                        if let e=error
                        {
                            TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                        }
                        else
                        {
                            TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while Electron is being flashed with Tinker firmware...", type: .Success)
                            //                                device.isFlashing = true
                            //                                self.deviceIDflashingDict[device.id] = kDefaultPhotonFlashingTime
                            //                                self.photonSelectionTableView.reloadData()
                            
                        }
                    })
                    
                }
            })
            areYouSureAlert.addAction(yesAction)
            areYouSureAlert.addAction(noAction)
            self.presentViewController(areYouSureAlert, animated: true, completion: nil)
            
        default:
            TSMessage.showNotificationWithTitle("Reflash Tinker", subtitle: "Cannot reflash Tinker to a non-Particle device", type: .Warning)
            
            
        }
        
    }

}