//
//  DeviceListViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

let deviceNamesArr : [String] = [ "aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "cracker", "cranky", "crazy", "dentist", "doctor", "dozen", "easter", "ferret", "gerbil", "hacker", "hamster", "hindu", "hobo", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "scrapple", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie" ]
let kDefaultCoreFlashingTime : Int = 30
let kDefaultPhotonFlashingTime : Int = 15


class DeviceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SparkSetupMainControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImage = UIImageView(image: UIImage(named: "imgTrianglifyBackgroundBlue")!)
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
        
        if !SparkCloud.sharedInstance().isLoggedIn
        {
            self.logoutButton.setTitle("Log in", forState: .Normal)
        }
//        backgroundImage.alpha = 0.85
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        srandom(arc4random())

    }

    @IBOutlet weak var logoutButton: UIButton!
    
    var devices : [SparkDevice] = []
    var deviceIDflashingDict : Dictionary<String,Int> = Dictionary()
    var deviceIDflashingTimer : NSTimer? = nil
    
    var selectedDevice : SparkDevice? = nil
    var lastTappedNonTinkerDevice : SparkDevice? = nil
    var refreshControlAdded : Bool = false
    
//    var deviceIDsBeingFlashed : Dictionary<String, Int> = Dictionary()
//    var flashingTimer : NSTimer? = nil
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBOutlet weak var setFlashingTestButton: UIButton!
//
//    @IBAction func setFlashingButtonTapped(sender: AnyObject) {
//        self.devices[0].isFlashing = true
//        self.deviceIDflashingDict[self.devices[0].id] = kDefaultPhotonFlashingTime
//
//        self.photonSelectionTableView.reloadData()
//        
//    }

    @IBOutlet weak var photonSelectionTableView: UITableView!
    
    @IBAction func setupNewDeviceButtonTapped(sender: UIButton) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Setup New Device", preferredStyle: .ActionSheet)
        
        // 2
        let setupCoreAction = UIAlertAction(title: "Core", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showSparkCoreAppPopUp()

        })

        let setupPhotonAction = UIAlertAction(title: "Photon", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.invokePhotonDeviceSetup()
        })

        let setupElectronAction = UIAlertAction(title: "Electron", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Electron setup placeholder")
            // TODO: Electron setup invoke
        })

        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(setupCoreAction)
        optionMenu.addAction(setupPhotonAction)
        optionMenu.addAction(setupElectronAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.deviceIDflashingTimer!.invalidate()
        if segue.identifier == "tinker"
        {
            self.lastTappedNonTinkerDevice = nil
//            self.flashingTimer?.invalidate()
            
            if let vc = segue.destinationViewController as? SPKTinkerViewController
            {
                vc.device = self.selectedDevice!
                
                var deviceTypeStr = "";
                switch vc.device.type
                {
                case .Photon:
                    deviceTypeStr = "Photon";
                    
                case .Electron:
                    deviceTypeStr = "Electron";
                    
                case .Core:
                    deviceTypeStr = "Core";
                    
                }
                
                Mixpanel.sharedInstance().track("Tinker: Start Tinkering", properties: ["device":deviceTypeStr, "running_tinker":vc.device.isRunningTinker()])

            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        if SparkCloud.sharedInstance().loggedInUsername != nil
        {
            self.loadDevices()
            
            self.deviceIDflashingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "flashingTimerFunc:", userInfo: nil, repeats: true)
        }
        Mixpanel.sharedInstance().timeEvent("Tinker: Device list screen activity")
    }
    
    override func viewWillDisappear(animated: Bool) {
        Mixpanel.sharedInstance().track("Tinker: Device list screen activity")
    }
    
    
    func flashingTimerFunc(timer : NSTimer)
    {
        for (deviceid, timeleft) in self.deviceIDflashingDict
        {
            if timeleft > 0
            {
                self.deviceIDflashingDict[deviceid]=timeleft-1
            }
            else
            {
                self.deviceIDflashingDict.removeValueForKey(deviceid)
                //self.photonSelectionTableView.reloadData()
                self.loadDevices()
            }
        }
    }
    
    func loadDevices()
    {
        var hud : MBProgressHUD
        
        // do a HUD only for first time load
        if self.refreshControlAdded == false
        {
            hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = .CustomView//.Indeterminate
            hud.animationType = .ZoomIn
            hud.labelText = "Loading"
            hud.minShowTime = 0.4
            
            // prepare spinner view for first time populating of devices into table
            let spinnerView : UIImageView = UIImageView(image: UIImage(named: "imgSpinner"))
            spinnerView.frame = CGRectMake(0, 0, 37, 37);
            spinnerView.contentMode = .ScaleToFill
            let rotation = CABasicAnimation(keyPath:"transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2*M_PI
            rotation.duration = 1.0;
            rotation.repeatCount = 1000; // Repeat
            spinnerView.layer.addAnimation(rotation,forKey:"Spin")
            
            hud.customView = spinnerView

        }
        

        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            SparkCloud.sharedInstance().getDevices({ (devices:[AnyObject]?, error:NSError?) -> Void in
                self.handleGetDevicesResponse(devices, error: error)
                
                // do anyway:
                dispatch_async(dispatch_get_main_queue()) {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    // first time add the custom pull to refresh control to the tableview
                    if self.refreshControlAdded == false
                    {
                        self.addRefreshControl()
                        self.refreshControlAdded = true
                    }
                }
            })
        }
    }
    
    
    
    func handleGetDevicesResponse(devices:[AnyObject]?, error:NSError?)
    {
        if let e = error
        {
            print("error listing devices for user \(SparkCloud.sharedInstance().loggedInUsername)")
            print(e.description)
            TSMessage.showNotificationWithTitle("Error", subtitle: "Error loading devices, please check internet connection.", type: .Error)
        }
        else
        {
            if let d = devices
            {
                self.devices = d as! [SparkDevice]
                
                // Sort alphabetically
                self.devices.sortInPlace({ (firstDevice:SparkDevice, secondDevice:SparkDevice) -> Bool in
                    if let n1 = firstDevice.name
                    {
                        if let n2 = secondDevice.name
                        {
                            return n1 < n2 //firstDevice.name < secondDevice.name
                        }
                    }
                    return false;
                    
                })

                // then sort by device type
                self.devices.sortInPlace({ (firstDevice:SparkDevice, secondDevice:SparkDevice) -> Bool in
                    return firstDevice.type.rawValue > secondDevice.type.rawValue
                })

                // and then by online/offline
                self.devices.sortInPlace({ (firstDevice:SparkDevice, secondDevice:SparkDevice) -> Bool in
                    return firstDevice.connected && !secondDevice.connected
                })
                
                // and then by running tinker or not
                self.devices.sortInPlace({ (firstDevice:SparkDevice, secondDevice:SparkDevice) -> Bool in
                    return firstDevice.isRunningTinker() && !secondDevice.isRunningTinker()
                })


            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.photonSelectionTableView.reloadData()
            }
        }
    }
    
    func addRefreshControl()
    {

//        let refreshFont = UIFont(name: "Gotham-Book", size: 17.0)
        
        self.photonSelectionTableView.addPullToRefreshWithPullText("Pull To Refresh", refreshingText: "Refreshing Devices") { () -> Void in
//        self.photonSelectionTableView.addPullToRefreshWithPullText("Pull To Refresh", pullTextColor: UIColor.whiteColor(), pullTextFont: refreshFont, refreshingText: "Refreshing Devices", refreshingTextColor: UIColor.whiteColor(), refreshingTextFont: refreshFont) { () -> Void in
            SparkCloud.sharedInstance().getDevices() { (devices:[AnyObject]?, error:NSError?) -> Void in
                self.handleGetDevicesResponse(devices, error: error)
                self.photonSelectionTableView.finishLoading()
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var masterCell : UITableViewCell?
        
        if indexPath.row < self.devices.count
        {
            let cell:DeviceTableViewCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("device_cell") as! DeviceTableViewCell
            if let name = self.devices[indexPath.row].name
            {
                cell.deviceNameLabel.text = name
            }
            else
            {
                cell.deviceNameLabel.text = "<no name>"
            }
            
            switch (self.devices[indexPath.row].type)
            {
            case .Core:
                cell.deviceImageView.image = UIImage(named: "imgCore")
                cell.deviceTypeLabel.text = "Core"

            case .Electron:
                cell.deviceImageView.image = UIImage(named: "imgElectron")
                cell.deviceTypeLabel.text = "Electron"

            case .Photon: // .Photon
                fallthrough
            default:
                cell.deviceImageView.image = UIImage(named: "imgPhoton")
                cell.deviceTypeLabel.text = "Photon"

            }

            cell.deviceIDLabel.text = devices[indexPath.row].id.uppercaseString
            
            let online = self.devices[indexPath.row].connected
            switch online
            {
            case true :
                switch devices[indexPath.row].isRunningTinker()
                {
                case true :
                    cell.deviceStateLabel.text = "Online"
                    cell.deviceStateImageView.image = UIImage(named: "imgGreenCircle") // TODO: breathing cyan
                default :
                    cell.deviceStateLabel.text = "Online, non-Tinker"
                    cell.deviceStateImageView.image = UIImage(named: "imgYellowCircle") // ?
                }
                
                
            default :
                cell.deviceStateLabel.text = "Offline"
                cell.deviceStateImageView.image = UIImage(named: "imgRedCircle") // gray circle
                
            }
            
            // override everything else
            if devices[indexPath.row].isFlashing || self.deviceIDflashingDict.keys.contains(devices[indexPath.row].id)
            {
                cell.deviceStateLabel.text = "Flashing"
                cell.deviceStateImageView.image = UIImage(named: "imgPurpleCircle") // gray circle
            }
            
            
            masterCell = cell
        }
               
        // make cell darker if it's even
        if (indexPath.row % 2) == 0
        {
            masterCell?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
        }
        else // lighter if even
        {
            masterCell?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        }
        
        return masterCell!
    }
    

    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // user swiped left
        if editingStyle == .Delete
        {
            TSMessage.showNotificationInViewController(self, title: "Unclaim confirmation", subtitle: "Are you sure you want to remove this device from your account?", image: UIImage(named: "imgQuestionWhite"), type: .Error, duration: -1, callback: { () -> Void in
                // callback for user dismiss by touching inside notification
                TSMessage.dismissActiveNotification()
                tableView.editing = false
                } , buttonTitle: " Yes ", buttonCallback: { () -> Void in
                    // callback for user tapping YES button - need to delete row and update table (TODO: actually unclaim device)
                    self.devices[indexPath.row].unclaim() { (error: NSError?) -> Void in
                        if let err = error
                        {
                            TSMessage.showNotificationWithTitle("Error", subtitle: err.localizedDescription, type: .Error)
                            self.photonSelectionTableView.reloadData()
                        }
                    }
                    
                    self.devices.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                    // update table view display to show dark/light cells with delay so that delete animation can complete nicely
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        tableView.reloadData()
                }}, atPosition: .Top, canBeDismissedByUser: true)
            }
        }
        
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Unclaim"
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        // user touches elsewhere
        TSMessage.dismissActiveNotification()
    }
    
    // prevent "Setup new photon" row from being edited/deleted
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row < self.devices.count
    }
    
    
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        if result == .Success
        {
            Mixpanel.sharedInstance().track("Tinker: Device setup activity", properties: ["result":"success"])
            
            if let deviceAdded = device
            {
                if (deviceAdded.name == nil)
                {
                    let deviceName = self.generateDeviceName()
                    deviceAdded.rename(deviceName, completion: { (error:NSError!) -> Void in
                        if let _=error
                        {
                            TSMessage.showNotificationWithTitle("Device added", subtitle: "You successfully added a new device to your account but there was a problem communicating with it. Device has been named \(deviceName).", type: .Warning)
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue()) {
                                TSMessage.showNotificationWithTitle("Success", subtitle: "You successfully added a new device to your account. Device has been named \(deviceName).", type: .Success)
                                self.photonSelectionTableView.reloadData()
                            }
                        }
                    })
                    

                }
                else
                {
                    TSMessage.showNotificationWithTitle("Success", subtitle: "You successfully added a new device to your account. Device is named \(deviceAdded.name).", type: .Success)
                    self.photonSelectionTableView.reloadData()

                }
            }
            else // Device is nil so we treat it as not claimed
            {
                TSMessage.showNotificationWithTitle("Success", subtitle: "You successfully setup the device Wi-Fi credentials. Verify its LED is breathing cyan.", type: .Success)
                self.photonSelectionTableView.reloadData()
            }
        }
        else if result == .SuccessNotClaimed
        {
            TSMessage.showNotificationWithTitle("Success", subtitle: "You successfully setup the device Wi-Fi credentials. Verify its LED is breathing cyan.", type: .Success)
            self.photonSelectionTableView.reloadData()
        }
        else
        {
            Mixpanel.sharedInstance().track("Device setup process", properties: ["result":"cancelled or failed"])
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Device setup did not complete.", type: .Warning)
        }
    }
    
    func invokePhotonDeviceSetup()
    {
        if let vc = SparkSetupMainController(setupOnly: !SparkCloud.sharedInstance().isLoggedIn)
        {
            Mixpanel.sharedInstance().timeEvent("Tinker: Device setup activity")
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }

    }
    
    
    func showSparkCoreAppPopUp()
    {
        Mixpanel.sharedInstance().track("Tinker: User wants to setup a Core")

        let popup = Popup(title: "Core setup", subTitle: "Setting up a Core requires the legacy Spark Core app. Do you want to install/open it now?", cancelTitle: "No", successTitle: "Yes", cancelBlock: {()->() in }, successBlock: {()->() in
            let sparkCoreAppStoreLink = "itms://itunes.apple.com/us/app/apple-store/id760157884?mt=8";
            Mixpanel.sharedInstance().track("Tinker: Send user to old Spark Core app")
            UIApplication.sharedApplication().openURL(NSURL(string: sparkCoreAppStoreLink)!)
        })
        popup.incomingTransition = .SlideFromBottom
        popup.outgoingTransition = .FallWithGravity
        popup.backgroundBlurType = .Dark
        popup.roundedCorners = true
        popup.tapBackgroundToDismiss = true
        popup.backgroundColor = UIColor.clearColor()// UIColor(red: 0, green: 123.0/255.0, blue: 181.0/255.0, alpha: 1.0) //UIColor(patternImage: UIImage(named: "imgTrianglifyBackgroundBlue")!)
        popup.titleColor = UIColor.whiteColor()
        popup.subTitleColor = UIColor.whiteColor()
        popup.successBtnColor = UIColor(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        popup.successTitleColor = UIColor.whiteColor()
        popup.cancelBtnColor = UIColor.clearColor()
        popup.cancelTitleColor = UIColor.whiteColor()
        popup.borderColor = UIColor.clearColor()
        popup.showPopup()
        
    }
    
    /*
    // keep track of devices being flashed with [device_id : seconds_left_to_flashing] dictionary
    func flashingTimerFunc(timer : NSTimer)
    {
        if self.deviceIDsBeingFlashed.count > 0
        {
            println(self.deviceIDsBeingFlashed)
            for id in deviceIDsBeingFlashed.keys
            {
                self.deviceIDsBeingFlashed[id] = self.deviceIDsBeingFlashed[id]! - 1
                if self.deviceIDsBeingFlashed[id]! < 1
                {
                    self.deviceIDsBeingFlashed.removeValueForKey(id)
                }
            }
        }
        else
        {
            self.flashingTimer?.invalidate()
        }
    }
    */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        TSMessage.dismissActiveNotification()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //                println("Tapped on \(self.devices[indexPath.row].description)")
        if devices[indexPath.row].isFlashing || self.deviceIDflashingDict.keys.contains(devices[indexPath.row].id)
        {
            TSMessage.showNotificationWithTitle("Device is being flashed", subtitle: "Device is currently being flashed, please wait for the process to finish.", type: .Warning)
            
        }
        else if self.devices[indexPath.row].connected
        {
            switch devices[indexPath.row].isRunningTinker()
            {
            case true :
                
                self.selectedDevice = self.devices[indexPath.row]
                self.performSegueWithIdentifier("tinker", sender: self)
            default :
                if let ntd = self.lastTappedNonTinkerDevice where self.devices[indexPath.row].id == ntd.id
                {
                    self.selectedDevice = self.devices[indexPath.row]
                    self.performSegueWithIdentifier("tinker", sender: self)
                }
                else
                {
                    let device = self.devices[indexPath.row]
                    self.lastTappedNonTinkerDevice = device
                    NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "resetLastTappedDevice:", userInfo: nil, repeats: false)
                    
                    // TODO: add "not running tinker, do you want to flash?"
                    TSMessage.showNotificationInViewController(self, title: "Device not running Tinker", subtitle: "Do you want to flash Tinker firmware to this device? Tap device again to Tinker with it anyway", image: UIImage(named: "imgQuestionWhite"), type: .Message, duration: -1, callback: { () -> Void in
                        // callback for user dismiss by touching inside notification
                        TSMessage.dismissActiveNotification()
                        } , buttonTitle: " Flash ", buttonCallback: { () -> Void in
                            self.lastTappedNonTinkerDevice = nil
                            
                            // TODO: duplicate code - fix
                            switch (device.type)
                            {
                            case .Core:
                                //                                        Mixpanel.sharedInstance().track("Tinker: Reflash Tinker",
                                Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Core"])
                                
                                device.flashKnownApp("tinker", completion: { (error:NSError!) -> Void in
                                    if let e=error
                                    {
                                        TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                                    }
                                    else
                                    {
                                        TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                                        //                                                self.deviceIDsBeingFlashed[device.id] = defaultFlashingTime
                                        //                                                self.flashingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "flashingTimerFunc:", userInfo: nil, repeats: true)
                                        device.isFlashing = true
                                        self.deviceIDflashingDict[device.id] = kDefaultCoreFlashingTime
                                        self.photonSelectionTableView.reloadData()
                                        
                                    }
                                })
                                
                            case .Photon:
                                Mixpanel.sharedInstance().track("Tinker: Reflash Tinker", properties: ["device":"Photon"])
                                
                                let bundle = NSBundle.mainBundle()
                                let path = bundle.pathForResource("photon-tinker", ofType: "bin")
                                //                                        var error:NSError?
                                if let binary: NSData? = NSData.dataWithContentsOfMappedFile(path!) as? NSData
                                {
                                    let filesDict = ["tinker.bin" : binary!]
                                    device.flashFiles(filesDict, completion: { (error:NSError!) -> Void in
                                        if let e=error
                                        {
                                            TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                                        }
                                        else
                                        {
                                            TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                                            //                                                    self.deviceIDsBeingFlashed[device.id] = defaultFlashingTime
                                            //                                                    self.flashingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "flashingTimerFunc:", userInfo: nil, repeats: true)
                                            device.isFlashing = true
                                            self.deviceIDflashingDict[device.id] = kDefaultPhotonFlashingTime
                                            self.photonSelectionTableView.reloadData()
                                            
                                        }
                                    })
                                    
                                }
                            case .Electron:
                                print("flash tinker to Electron");
                                // TODO: flash tinker to Electron
                                
                            }
                        }, atPosition: .Top, canBeDismissedByUser: true)
                    
                    
                    //TSMessage.showNotificationWithTitle("Device not running Tinker", subtitle: "This device firmware is not Tinker, tap it again if you want to Tinker with it anyway.", type: .Warning)
                    
                }
            }
            
        }
        else
        {
            self.lastTappedNonTinkerDevice = nil
            TSMessage.showNotificationWithTitle("Device offline", subtitle: "This device is offline, please turn it on and refresh in order to Tinker with it.", type: .Error)
        }
    }
    



    func resetLastTappedDevice(timer : NSTimer)
    {
        print("lastTappedNonTinkerDevice reset")
        self.lastTappedNonTinkerDevice = nil
    }


    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }




    @IBAction func logoutButtonTapped(sender: UIButton) {
        SparkCloud.sharedInstance().logout()
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }

    }
    
    
    func generateDeviceName() -> String
    {
        let name : String = deviceNamesArr[Int(arc4random_uniform(UInt32(deviceNamesArr.count)))] + "_" + deviceNamesArr[Int(arc4random_uniform(UInt32(deviceNamesArr.count)))]
        
        return name
    }

    
}
