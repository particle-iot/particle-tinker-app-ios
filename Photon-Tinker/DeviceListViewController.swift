//
//  DeviceListViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit
import QuartzCore
//import TSMessageView


let deviceNamesArr : [String] = [ "aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "cracker", "cranky", "crazy", "dentist", "doctor", "dozen", "easter", "ferret", "gerbil", "hacker", "hamster", "hindu", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "scrapple", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie" ]

let kDefaultCoreFlashingTime : Int = 30
let kDefaultPhotonFlashingTime : Int = 15
let kDefaultElectronFlashingTime : Int = 15

class DeviceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SparkSetupMainControllerDelegate, SparkDeviceDelegate {
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        TSMessageView.appearance().setTitleFont(UIFont(name: "Gotham-book", size: 13.0)var       
        
        
        if !SparkCloud.sharedInstance().isAuthenticated
        {
            self.logoutButton.setTitle("Log in", forState: .Normal)
        }
        //        backgroundImage.alpha = 0.85
        srandom(arc4random())
        
        
        
        ZAlertView.positiveColor            = ParticleUtils.particleCyanColor
        ZAlertView.negativeColor            = ParticleUtils.particlePomegranateColor
        ZAlertView.blurredBackground        = true
        ZAlertView.showAnimation            = .BounceBottom
        ZAlertView.hideAnimation            = .BounceBottom
//        ZAlertView.initialSpringVelocity    = 0.5
        ZAlertView.duration                 = 0.9
        ZAlertView.cornerRadius             = 4.0
        ZAlertView.textFieldTextColor       = ParticleUtils.particleDarkGrayColor
        ZAlertView.textFieldBackgroundColor = UIColor.whiteColor()
        ZAlertView.textFieldBorderColor     = UIColor.color("#777777")
        ZAlertView.buttonFont               = UIFont(name: "Gotham-medium", size: 15.0)
        ZAlertView.messageFont              = UIFont(name: "Gotham-book", size: 15.0)
        ZAlertView.buttonHeight             = 48.0
    }
    
        
    
    @IBOutlet weak var setupNewDeviceButton: UIButton!
    
    func appDidBecomeActive(sender : AnyObject) {
//        print("appDidBecomeActive observer triggered")
        //        self.animateOnlineIndicators()
        self.photonSelectionTableView.reloadData()
        
    }
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var devices : [SparkDevice] = []
    var selectedDevice : SparkDevice? = nil
    var refreshControlAdded : Bool = false
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var photonSelectionTableView: UITableView!
    
    @IBAction func setupNewDeviceButtonTapped(sender: UIButton) {
        
        // heading
        // TODO: format with Particle cyan and Gotham font!
        
        
        
        let dialog = ZAlertView(title: "Setup a new device", message: nil, alertType: .MultipleChoice)
        
        
        dialog.addButton("Photon", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            self.invokePhotonDeviceSetup()
            
        }
        dialog.addButton("Electron/SIM", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            if SparkCloud.sharedInstance().loggedInUsername != nil {
                self.invokeElectronSetup()
            } else {
                TSMessage.showNotificationWithTitle("Authentication", subtitle: "You must be logged to your Particle account in to setup an Electron ", type: .Error)
            }
            
            
        }
        
        dialog.addButton("Core", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            dialog.dismiss()
            self.showSparkCoreAppPopUp()
            
        }

        dialog.addButton("Cancel", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.whiteColor()) { (dialog : ZAlertView) in
            dialog.dismiss()
        }


        dialog.show()

        
        
    }
    
    func invokeElectronSetup() {
        SEGAnalytics.sharedAnalytics().track("Tinker: Electron setup invoked")
        let esVC : ElectronSetupViewController = self.storyboard!.instantiateViewControllerWithIdentifier("electronSetup") as! ElectronSetupViewController
        self.presentViewController(esVC, animated: true, completion: nil)
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let deviceInfo = ParticleUtils.getDeviceTypeAndImage(self.selectedDevice)
        
        if segue.identifier == "tinker" {
            if let vc = segue.destinationViewController as? SPKTinkerViewController {
                vc.device = self.selectedDevice
                
                SEGAnalytics.sharedAnalytics().track("Tinker: Start Tinkering", properties: ["device":deviceInfo.deviceType, "running_tinker":vc.device.isRunningTinker()])
                
            }
        }
        
        if segue.identifier == "deviceInspector" {
            if let vc = segue.destinationViewController as? DeviceInspectorViewController {
                vc.device = self.selectedDevice
                
                SEGAnalytics.sharedAnalytics().track("Tinker: Device Inspector", properties: ["device":deviceInfo.deviceType])
                
            }
        }
    }

    

    var statusEventID : AnyObject? // TODO: remove
    
    override func viewWillAppear(animated: Bool) {
        
        if let d = self.selectedDevice {
            d.delegate = self // reassign Device delegate to this VC to receive system events (in case some other VC down the line reassigned it)
        }
        
        if SparkCloud.sharedInstance().isAuthenticated
        {
            
            self.loadDevices()
            
            /*
            print("! subscribing to status event") // TODO: remove
            self.statusEventID = SparkCloud.sharedInstance().subscribeToMyDevicesEventsWithPrefix("spark", handler: { (event: SparkEvent?, error: NSError?) in
                // if we received a status event so probably one of the device came online or offline - update the device list
                if error == nil {
                    self.loadDevices()
//                self.animateOnlineIndicators()
                    print("! got status event: "+event!.description)
                }
            })
            */
            
        }
        SEGAnalytics.sharedAnalytics().track("Tinker: Device list screen activity")
//        animateOnlineIndicators()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
    }
    
    
    
    
    func showTutorial() {
        
       if ParticleUtils.shouldDisplayTutorialForViewController(self) {
    
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                if self.navigationController?.visibleViewController == self {
                    // viewController is visible
                    
                    // 3
//                    var tutorial = YCTutorialBox(headline: "Logout", withHelpText: "Tap to logout from your account and switch to a different user.")
//                    tutorial.showAndFocusView(self.logoutButton)
                    
                    // 2
                    var tutorial = YCTutorialBox(headline: "Setup a new device", withHelpText: "Tap the plus button to set up a new Photon or Electron device you wish to add to your account")
                    
                    tutorial.showAndFocusView(self.setupNewDeviceButton)
                    
                    
                    // 1
                    let firstDeviceCell = self.photonSelectionTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) // TODO: what is theres not cell
                    tutorial = YCTutorialBox(headline: "Your devices", withHelpText: "See and manage your devices.\n\nOnline devices have their indicator 'breathing' cyan, offline ones are gray.\n\nTap a device to enter Tinker or Device Inspector mode, device must run Tinker firmware to enter Tinker mode.\n\nSwipe left to remove a device from your account.\n\nPull down to refresh your list.")
                    
                    tutorial.showAndFocusView(firstDeviceCell)
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
                
            }
        }
    }
    
    
    
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    
    

    
    func loadDevices()
    {
        // do a HUD only for first time load
        if self.refreshControlAdded == false
        {
            ParticleSpinner.show(self.view)
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            SparkCloud.sharedInstance().getDevices({ (devices:[AnyObject]?, error:NSError?) -> Void in
                
                self.handleGetDevicesResponse(devices, error: error)
                
                // do anyway:
                dispatch_async(dispatch_get_main_queue()) {[unowned self] () -> () in
                    ParticleSpinner.hide(self.view)
                    // first time add the custom pull to refresh control to the tableview
                    if self.refreshControlAdded == false
                    {
                        self.addRefreshControl()
                        self.refreshControlAdded = true
                    }
                    self.showTutorial()
                }
            })
        }
    }
    
    
    
    func handleGetDevicesResponse(devices:[AnyObject]?, error:NSError?)
    {
        if let e = error
        {
            //            print("error listing devices for user \(SparkCloud.sharedInstance().loggedInUsername)")
            //            print(e.description)
            if e.code == 401 {
                //                print("invalid access token - logging out")
                self.logoutButtonTapped(self.logoutButton)
            } else {
                TSMessage.showNotificationWithTitle("Error", subtitle: "Error loading devices, please check your internet connection.", type: .Error)
            }
            self.noDevicesLabel.hidden = false
        }
        else
        {
            if let d = devices
            {
                self.devices = d as! [SparkDevice]
                
                for device in self.devices {
                    device.delegate = self
                }
                
                self.noDevicesLabel.hidden = self.devices.count == 0 ? false : true
                
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
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.photonSelectionTableView.reloadData()
                }

                
            } else {
                self.noDevicesLabel.hidden = false
            }
            
        }
    }
    
    func addRefreshControl()
    {
        
        //        let refreshFont = UIFont(name: "Gotham-Book", size: 17.0)
        
        self.photonSelectionTableView.addPullToRefreshWithPullText("Pull To Refresh", refreshingText: "Refreshing Devices") { () -> Void in
            //        self.photonSelectionTableView.addPullToRefreshWithPullText("Pull To Refresh", pullTextColor: UIColor.whiteColor(), pullTextFont: refreshFont, refreshingText: "Refreshing Devices", refreshingTextColor: UIColor.whiteColor(), refreshingTextFont: refreshFont) { () -> Void in
            weak var weakSelf = self
            SparkCloud.sharedInstance().getDevices() { (devices:[AnyObject]?, error:NSError?) -> Void in
                weakSelf?.handleGetDevicesResponse(devices, error: error)
                weakSelf?.photonSelectionTableView.finishLoading()
//                weakSelf?.animateOnlineIndicators()
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    @IBOutlet weak var noDevicesLabel: UILabel!
    
    
    internal func getDeviceStateDescription(device : SparkDevice?) -> String {
        let online = device?.connected
        
        switch online!
        {
        case true :
            switch device!.isRunningTinker()
            {
            case true :
                return "Tinker" // Online (Tinker)
                
            default :
                return "" //Online
            }
            
            
        default :
            return "" //Offline
            
        }
        
    }
    
    
    
    /*
    func animateOnlineIndicators() {
        
        for row in 0..<self.photonSelectionTableView.numberOfRowsInSection(0) {
            
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let deviceCell = self.photonSelectionTableView.cellForRowAtIndexPath(indexPath) as! DeviceTableViewCell?
            
            if let cell = deviceCell { // if cell is not visibile it'll be nil
                self.animateOnlineIndicatorImageView(cell.deviceStateImageView, online: self.devices[indexPath.row].connected)
            }
        }
    }
     */
    
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
            
            let deviceInfo = ParticleUtils.getDeviceTypeAndImage(self.devices[indexPath.row])

            cell.deviceImageView.image = deviceInfo.deviceImage
            cell.deviceTypeLabel.text = "  "+deviceInfo.deviceType+"  "
//            cell.deviceTypeLabel.backgroundColor = UIColor(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 0.72)
            
            let deviceTypeColor = ParticleUtils.particleCyanColor// UIColor(red: 0, green: 157.0/255.0, blue: 207.0/255.0, alpha: 1.0)
            cell.deviceTypeLabel.layer.borderColor = deviceTypeColor.CGColor
            cell.deviceTypeLabel.textColor = deviceTypeColor
            
            cell.deviceTypeLabel.layer.borderWidth = 1.0
//            cell.deviceTypeLabel.textColor = UIColor(white: 0.96, alpha: 1.0)
            cell.deviceTypeLabel.layer.cornerRadius = 4.0
            cell.deviceTypeLabel.layer.masksToBounds = true

//            cell.deviceIDLabel.text = ""//devices[indexPath.row].id.uppercaseString
            

            let deviceStateInfo = getDeviceStateDescription(devices[indexPath.row])
            cell.deviceStateLabel.text = deviceStateInfo
            
            
            
            ParticleUtils.animateOnlineIndicatorImageView(cell.deviceStateImageView, online: self.devices[indexPath.row].connected, flashing:self.devices[indexPath.row].isFlashing)
            

            // override everything else
            if devices[indexPath.row].isFlashing
            {
//                cell.deviceStateLabel.text = "Flashing"
                cell.deviceStateImageView.image = UIImage(named: "imgCircle") // TDO blink this -
            }
            
            
            masterCell = cell
        }
        
               
        return masterCell!
    }
    
    
    func sparkDevice(device: SparkDevice, didReceiveSystemEvent event: SparkDeviceSystemEvent) {
//        print("--> Received system event "+String(event.rawValue)+" from device "+device.name!)
        
        if (event == .FlashStarted) {
            for cell in self.photonSelectionTableView.visibleCells {
                let deviceCell = cell as! DeviceTableViewCell
                if deviceCell.deviceNameLabel.text == device.name {
//                    deviceCell.awakeFromNib()
                    dispatch_async(dispatch_get_main_queue()) {
                        deviceCell.deviceStateLabel.text = "(Flashing)"
                    }
                    ParticleUtils.animateOnlineIndicatorImageView(deviceCell.deviceStateImageView, online: true, flashing: true)
                }
            }
        } else {
            self.loadDevices()
        }
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
        return "Remove"
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
            SEGAnalytics.sharedAnalytics().track("Tinker: Photon setup ended", properties: ["result":"success"])
            
            if let deviceAdded = device
            {
                if (deviceAdded.name == nil)
                {
                    let deviceName = self.generateDeviceName()
                    deviceAdded.rename(deviceName, completion: { (error:NSError?) -> Void in
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
                    TSMessage.showNotificationWithTitle("Success", subtitle: "You successfully added a new device to your account. Device is named \(deviceAdded.name!).", type: .Success)
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
            SEGAnalytics.sharedAnalytics().track("Photon setup ended", properties: ["result":"cancelled or failed"])
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Device setup did not complete.", type: .Warning)
        }
    }
    
    
    func customizeSetupForSetupFlow()
    {
        let c = SparkSetupCustomization.sharedInstance()
        
        c.pageBackgroundColor = UIColor.color("#F0F0F0")!//ParticleUtils.particleAlmostWhiteColor
        c.pageBackgroundImage = nil
        
        c.normalTextColor = ParticleUtils.particleDarkGrayColor// UIColor.whiteColor()
        c.linkTextColor = UIColor.blueColor()
        c.brandImageBackgroundColor = UIColor(patternImage: UIImage(named: "imgTrianglifyBackgroundBlue")!)
        
        c.elementTextColor = UIColor.whiteColor()//(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 1.0) //(patternImage: UIImage(named: "imgOrangeGradient")!)
        c.elementBackgroundColor = ParticleUtils.particleCyanColor
        c.brandImage = UIImage(named: "particle-horizontal-head")
        
        c.tintSetupImages = false
        c.instructionalVideoFilename = "photon_wifi.mp4"
        c.allowPasswordManager = true
        c.lightStatusAndNavBar = true
        c.disableLogOutOption = true
        
    }

    
    func invokePhotonDeviceSetup()
    {
//        let dsc = SparkSetupCustomization.sharedInstance()
//        dsc.brandImage = UIImage(named: "setup-device-header")
        
        self.customizeSetupForSetupFlow()
        if let vc = SparkSetupMainController(setupOnly: !SparkCloud.sharedInstance().isAuthenticated)
        {
            SEGAnalytics.sharedAnalytics().track("Tinker: Photon setup invoked")
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    
    func showSparkCoreAppPopUp()
    {
        SEGAnalytics.sharedAnalytics().track("Tinker: User wants to setup a Core")
        
        let dialog = ZAlertView(title: "Core setup", message: "Setting up a Core requires the legacy Spark Core app. Do you want to install/open it now?", isOkButtonLeft: true, okButtonText: "Yes", cancelButtonText: "No",
                                okButtonHandler: { alertView in
                                    alertView.dismiss()
                                    let sparkCoreAppStoreLink = "itms://itunes.apple.com/us/app/apple-store/id760157884?mt=8";
                                    SEGAnalytics.sharedAnalytics().track("Tinker: Send user to old Spark Core app")
                                    UIApplication.sharedApplication().openURL(NSURL(string: sparkCoreAppStoreLink)!)
                                    
            },
                                cancelButtonHandler: { alertView in
                                    alertView.dismiss()
            }
        )

        
        
        dialog.show()

        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        TSMessage.dismissActiveNotification()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let device = self.devices[indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //                println("Tapped on \(self.devices[indexPath.row].description)")
        if devices[indexPath.row].isFlashing
        {
            TSMessage.showNotificationWithTitle("Device is being flashed", subtitle: "Device is currently being flashed, please wait for the process to finish.", type: .Warning)
            
        } else if device.connected && device.isRunningTinker() {
            self.selectedDevice = self.devices[indexPath.row]
            self.performSegueWithIdentifier("tinker", sender: self)
        } else {
            self.selectedDevice = self.devices[indexPath.row]
            self.performSegueWithIdentifier("deviceInspector", sender: self)
        }
    }
    
    


    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }


    func logoutButtonTapped(sender: UIButton) {
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
