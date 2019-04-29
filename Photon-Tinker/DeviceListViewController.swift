//
//  DeviceListViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit
import QuartzCore
//import TSMessageView


let deviceNamesArr : [String] = [ "aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "cracker", "cranky", "crazy", "dentist", "doctor", "dozen", "easter", "ferret", "gerbil", "hacker", "hamster", "hindu", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "scrapple", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie" ]

let kDefaultCoreFlashingTime : Int = 30
let kDefaultPhotonFlashingTime : Int = 15
let kDefaultElectronFlashingTime : Int = 15

class DeviceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParticleSetupMainControllerDelegate, ParticleDeviceDelegate {


    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        TSMessageView.appearance().setTitleFont(UIFont(name: "Gotham-book", size: 13.0)var       
        
        
        if !ParticleCloud.sharedInstance().isAuthenticated
        {
            self.logoutButton.setTitle("Log in", for: UIControlState())
        }
        //        backgroundImage.alpha = 0.85
        srandom(arc4random())
        
        
        
        ZAlertView.positiveColor            = ParticleUtils.particleCyanColor
        ZAlertView.negativeColor            = ParticleUtils.particlePomegranateColor
        ZAlertView.blurredBackground        = true
        ZAlertView.showAnimation            = .fadeIn
        ZAlertView.hideAnimation            = .fadeOut
        ZAlertView.duration                 = 0.25
        ZAlertView.cornerRadius             = 4.0
        ZAlertView.textFieldTextColor       = ParticleUtils.particleDarkGrayColor
        ZAlertView.textFieldBackgroundColor = UIColor.white
        ZAlertView.textFieldBorderColor     = UIColor.color("#777777")
        ZAlertView.buttonFont               = UIFont(name: "Gotham-medium", size: 15.0)
        ZAlertView.messageFont              = UIFont(name: "Gotham-book", size: 15.0)
        ZAlertView.buttonHeight             = 48.0
    }
    
        
    
    @IBOutlet weak var setupNewDeviceButton: UIButton!
    
    @objc func appDidBecomeActive(_ sender : AnyObject) {
        self.photonSelectionTableView.reloadData()
    }
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var devices : [ParticleDevice] = []
    var selectedDevice : ParticleDevice? = nil
    var refreshControlAdded : Bool = false

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var photonSelectionTableView: UITableView!
    
    @IBAction func setupNewDeviceButtonTapped(_ sender: UIButton) {
        // heading
        // TODO: format with Particle cyan and Gotham font!

        let dialog = ZAlertView(title: "Set up a new device", message: nil, alertType: .multipleChoice)

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            dialog.addButton("Argon / Boron / Xenon", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog: ZAlertView) in
                dialog.dismiss()
                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Mesh setup started", withParameters: getVaList([]))
                self.invokeMeshDeviceSetup()

            }

//            dialog.addButton("A / B Series", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog: ZAlertView) in
//                dialog.dismiss()
//                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Mesh SoM setup started", withParameters: getVaList([]))
//                self.invokeMeshDeviceSetup()
//
//            }
        }
        
        dialog.addButton("Photon", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()

            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup started", withParameters: getVaList([]))

            self.invokePhotonDeviceSetup()
            
        }
        dialog.addButton("Electron / SIM", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismiss()
            
            if ParticleCloud.sharedInstance().loggedInUsername != nil {
                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Electron setup started", withParameters: getVaList([]))
                self.invokeElectronSetup()
            } else {
                RMessage.showNotification(withTitle: "Authentication", subtitle: "You must be logged to your Particle account in to setup an Electron ", type: .error, customTypeName: nil, callback: nil)
            }
            
            
        }
        
        dialog.addButton("Core", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            dialog.dismissWithDuration(0.01)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { () -> Void in
                self.showParticleCoreAppPopUp()
            }
        }

        dialog.addButton("Cancel", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.white) { (dialog : ZAlertView) in
            dialog.dismiss()
        }


        dialog.show()

        
        
    }
    
    func invokeElectronSetup() {
        SEGAnalytics.shared().track("Tinker_ElectronSetupInvoked")
        let esVC : ElectronSetupViewController = self.storyboard!.instantiateViewController(withIdentifier: "electronSetup") as! ElectronSetupViewController
        self.present(esVC, animated: true, completion: nil)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceInspector" {
            if let vc = segue.destination as? DeviceInspectorViewController {
                let indexPath = sender as! IndexPath
                vc.setup(device: self.devices[indexPath.row])

                let deviceInfo = ParticleUtils.getDeviceTypeAndImage(self.devices[indexPath.row])

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Segue into device inspector - idx: %i device: %@", withParameters: getVaList([indexPath.row, "\(self.devices[indexPath.row])"]))

                SEGAnalytics.shared().track("Tinker_SegueToDeviceInspector", properties: ["device":deviceInfo.deviceType])
                
            }
        }
    }

    

    var statusEventID : AnyObject? // TODO: remove
    
    override func viewWillAppear(_ animated: Bool) {
        if let d = self.selectedDevice {
            d.delegate = self // reassign Device delegate to this VC to receive system events (in case some other VC down the line reassigned it)
        }
        
        if ParticleCloud.sharedInstance().isAuthenticated
        {
            
            self.loadDevices()
            
            /*
            print("! subscribing to status event") // TODO: remove
            self.statusEventID = ParticleCloud.sharedInstance().subscribeToMyDevicesEventsWithPrefix("particle", handler: { (event: ParticleEvent?, error: NSError?) in
                // if we received a status event so probably one of the device came online or offline - update the device list
                if error == nil {
                    self.loadDevices()
//                self.animateOnlineIndicators()
                    print("! got status event: "+event!.description)
                }
            })
            */
        }

        SEGAnalytics.shared().track("Tinker_DeviceListScreenActivity")
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }


    func showTutorial() {
        
       if ParticleUtils.shouldDisplayTutorialForViewController(self) {
    
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if self.navigationController?.visibleViewController == self {
                    // viewController is visible
                    
                    // 3
//                    var tutorial = YCTutorialBox(headline: "Logout", withHelpText: "Tap to logout from your account and switch to a different user.")
//                    tutorial.showAndFocusView(self.logoutButton)
                    
                    // 2
                    var tutorial = YCTutorialBox(headline: "Setup a new device", withHelpText: "Tap the plus button to set up a new Photon or Electron device you wish to add to your account")
                    
                    tutorial?.showAndFocus(self.setupNewDeviceButton)
                    
                    
                    // 1
                    let firstDeviceCell = self.photonSelectionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) // TODO: what is theres not cell
                    tutorial = YCTutorialBox(headline: "Your devices", withHelpText: "See and manage your devices.\n\nOnline devices have their indicator 'breathing' cyan, offline ones are gray.\n\nTap a device to enter Tinker or Device Inspector mode, device must run Tinker firmware to enter Tinker mode.\n\nSwipe left to remove a device from your account.\n\nPull down to refresh your list.")
                    
                    tutorial?.showAndFocus(firstDeviceCell)
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
                
            }
        }
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    
    func loadDevices()
    {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices started", withParameters: getVaList([]))


        // do a HUD only for first time load
        if self.refreshControlAdded == false
        {
            ParticleSpinner.show(self.view)
        }
        
        DispatchQueue.global().async {
            
            ParticleCloud.sharedInstance().getDevices({ (devices:[ParticleDevice]?, error:Error?) -> Void in
                
                
                self.handleGetDevicesResponse(devices, error: error)
                
                // do anyway:
                DispatchQueue.main.async {[weak self] () -> () in
                    if let s = self {
                        ParticleSpinner.hide(s.view)
                        // first time add the custom pull to refresh control to the tableview
                        if s.refreshControlAdded == false
                        {
                            s.addRefreshControl()
                            s.refreshControlAdded = true
                        }
                        s.showTutorial()
                    }
                }
            })
        }
    }
    
    
    
    func handleGetDevicesResponse(_ devices:[ParticleDevice]?, error:Error?)
    {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed", withParameters: getVaList([]))
        if let e = error
        {
            //            print("error listing devices for user \(ParticleCloud.sharedInstance().loggedInUsername)")
            //            print(e.description)
            if (e as NSError).code == 401 {
                //                print("invalid access token - logging out")
                self.logout()
            } else {
                ParticleLogger.logError(NSStringFromClass(type(of: self)), format: "Load devices error", withParameters: getVaList([]))
                RMessage.showNotification(withTitle: "Error", subtitle: "Error loading devices, please check your internet connection.", type: .error, customTypeName: nil, callback: nil)
            }

            DispatchQueue.main.async {
                self.noDevicesLabel.isHidden = false
            }
        }
        else
        {
            if let d = devices
            {
                // if no devices offer user to setup a new one
                if (d.count == 0) {
                    self.setupNewDeviceButtonTapped(self.setupNewDeviceButton)
                }

                self.devices = d
                
                for device in self.devices {
                    device.delegate = self
                }
                
                self.noDevicesLabel.isHidden = self.devices.count == 0 ? false : true

                self.devices.sort(by: { (firstDevice:ParticleDevice, secondDevice:ParticleDevice) -> Bool in
                    if (firstDevice.connected != secondDevice.connected) {
                        return firstDevice.connected == true
                    } else {
                        var nameA = firstDevice.name ?? " "
                        var nameB = secondDevice.name ?? " "
                        return nameA.lowercased() < nameB.lowercased()
                    }
                })

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed. Device count: %i", withParameters: getVaList([self.devices.count]))
                ParticleLogger.logDebug(NSStringFromClass(type(of: self)), format: "Devices: %@", withParameters: getVaList([self.devices]))

                DispatchQueue.main.async {
                    self.photonSelectionTableView.reloadData()
                }

                
            } else {
                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed. Device count: %i", withParameters: getVaList([self.devices.count]))
                ParticleLogger.logDebug(NSStringFromClass(type(of: self)), format: "Devices: %@", withParameters: getVaList([self.devices]))

                DispatchQueue.main.async {
                    self.noDevicesLabel.isHidden = false
                    self.setupNewDeviceButtonTapped(self.setupNewDeviceButton)
                }
            }
            
        }
    }
    
    func addRefreshControl()
    {
        self.photonSelectionTableView.addPullToRefresh(withPullText: "Pull To Refresh", refreshingText: "Refreshing Devices") { () -> Void in
            weak var weakSelf = self
            ParticleCloud.sharedInstance().getDevices() { (devices:[ParticleDevice]?, error: Error?) -> Void in
                weakSelf?.handleGetDevicesResponse(devices, error: error)
                weakSelf?.photonSelectionTableView.finishLoading()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    @IBOutlet weak var noDevicesLabel: UILabel!
    
    
    internal func getDeviceStateDescription(_ device : ParticleDevice?) -> String {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var masterCell : UITableViewCell?
        
        if (indexPath as NSIndexPath).row < self.devices.count
        {
            let cell:DeviceTableViewCell = self.photonSelectionTableView.dequeueReusableCell(withIdentifier: "device_cell") as! DeviceTableViewCell
            if let name = self.devices[(indexPath as NSIndexPath).row].name
            {
                cell.deviceNameLabel.text = name
            }
            else
            {
                cell.deviceNameLabel.text = "<no name>"
            }
            
            let deviceInfo = ParticleUtils.getDeviceTypeAndImage(self.devices[(indexPath as NSIndexPath).row])

            cell.deviceImageView.image = deviceInfo.deviceImage
            cell.deviceTypeLabel.text = "  "+deviceInfo.deviceType+"  "
            
            let deviceTypeColor = ParticleUtils.particleCyanColor// UIColor(red: 0, green: 157.0/255.0, blue: 207.0/255.0, alpha: 1.0)
            cell.deviceTypeLabel.layer.borderColor = deviceTypeColor.cgColor
            cell.deviceTypeLabel.textColor = deviceTypeColor
            
            cell.deviceTypeLabel.layer.borderWidth = 1.0
            cell.deviceTypeLabel.layer.cornerRadius = 4.0
            cell.deviceTypeLabel.layer.masksToBounds = true

            let deviceStateInfo = getDeviceStateDescription(devices[(indexPath as NSIndexPath).row])
            cell.deviceStateLabel.text = deviceStateInfo
            
            
            
            ParticleUtils.animateOnlineIndicatorImageView(cell.deviceStateImageView, online: self.devices[(indexPath as NSIndexPath).row].connected, flashing:self.devices[(indexPath as NSIndexPath).row].isFlashing)
            

            // override everything else
            if devices[(indexPath as NSIndexPath).row].isFlashing
            {
                cell.deviceStateImageView.image = UIImage(named: "imgCircle")
            }
            
            masterCell = cell
        }
        return masterCell!
    }
    
    
    func particleDevice(_ device: ParticleDevice, didReceive event: ParticleDeviceSystemEvent) {
//        print("--> Received system event "+String(event.rawValue)+" from device "+device.name!)
        
        if (event == .flashStarted) {
            for cell in self.photonSelectionTableView.visibleCells {
                let deviceCell = cell as! DeviceTableViewCell
                if deviceCell.deviceNameLabel.text == device.name {
//                    deviceCell.awakeFromNib()
                    DispatchQueue.main.async {
                        deviceCell.deviceStateLabel.text = "(Flashing)"
                    }
                    ParticleUtils.animateOnlineIndicatorImageView(deviceCell.deviceStateImageView, online: true, flashing: true)
                }
            }
        } else {
            self.loadDevices()
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // user swiped left
        if editingStyle == .delete
        {

            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Showing unclaim confirmation", withParameters: getVaList([]))

            let alert = UIAlertController(title: "Unclaim confirmation", message: "Are you sure you want to remove this device from your account?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Unclaim", style: .default) { action in

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Unclaiming device: %@", withParameters: getVaList([self.devices[(indexPath as NSIndexPath).row]]))

                self.devices[(indexPath as NSIndexPath).row].unclaim() { (error: Error?) -> Void in
                    if let err = error
                    {
                        RMessage.showNotification(withTitle: "Error", subtitle: err.localizedDescription, type: .error, customTypeName: nil, callback: nil)
                        self.photonSelectionTableView.reloadData()
                    }
                }

                self.devices.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device unclaim complete. Device count: %i, Devices: %@", withParameters: getVaList([self.devices.count, self.devices]))

                // update table view display to show dark/light cells with delay so that delete animation can complete nicely
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    tableView.reloadData()
                }
            })
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }

    
    // prevent "Setup new photon" row from being edited/deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath as NSIndexPath).row < self.devices.count
    }
    
    
    func showSetupSuccessMessageAndReload() {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Setup success message and reloading table view", withParameters: getVaList([]))

        if (self.devices.count <= 1) {
            RMessage.showNotification(withTitle: "Success", subtitle: "Nice, you've successfully set up your first Particle! You'll be receiving a welcome email with helpful tips and links to resources. Start developing by going to https://build.particle.io/ on your computer, or stay here and enjoy the magic of Tinker.", type: .success, customTypeName: nil, callback: nil)
        } else {
            RMessage.showNotification(withTitle: "Success", subtitle: "You successfully added a new device to your account.", type: .success, customTypeName: nil, callback: nil)
        }
        self.photonSelectionTableView.reloadData()

    }
    
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!) {
        if result == .success
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup ended", withParameters: getVaList([]))
            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"success"])
            
            if let deviceAdded = device
            {
                if (deviceAdded.name == nil) // might be the setup naminh BUG here
                {
                    print("! null name device detected"); //@@@
                    
                    let deviceName = MeshSetupStrings.getRandomDeviceName()
                    deviceAdded.rename(deviceName, completion: { (error : Error?) -> Void in
                        if let _=error
                        {
                            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Added a new device to account but there was a problem communicating with it. Device has been named %@.", withParameters: getVaList([deviceName]))
                            RMessage.showNotification(withTitle: "Device added", subtitle: "You successfully added a new device to your account but there was a problem communicating with it. Device has been named \(deviceName).", type: .warning, customTypeName: nil, callback: nil)
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.showSetupSuccessMessageAndReload()
                            }
                        }
                    })
                    
                    
                }
                else
                {
                    self.showSetupSuccessMessageAndReload()
                }
            }
            else // Device is nil so we treat it as not claimed
            {
                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "You successfully setup the device Wi-Fi credentials.", withParameters: getVaList([]))

                RMessage.showNotification(withTitle: "Success", subtitle: "You successfully setup the device Wi-Fi credentials. Verify its LED is breathing cyan.", type: .success, customTypeName: nil, callback: nil)
                self.photonSelectionTableView.reloadData()
            }
        }
        else if result == .successNotClaimed
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "You successfully setup the device Wi-Fi credentials.", withParameters: getVaList([]))

            RMessage.showNotification(withTitle: "Success", subtitle: "You successfully setup the device Wi-Fi credentials. Verify its LED is breathing cyan.", type: .success, customTypeName: nil, callback: nil)
            self.photonSelectionTableView.reloadData()
        }
        else
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup cancelled or failed.", withParameters: getVaList([]))

            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"cancelled or failed"])
            RMessage.showNotification(withTitle: "Warning", subtitle: "Device setup did not complete.", type: .warning, customTypeName: nil, callback: nil)
        }
    }
    
    
    func customizeSetupForSetupFlow()
    {
        let c = ParticleSetupCustomization.sharedInstance()
        
        c?.pageBackgroundColor = UIColor.color("#F0F0F0")!//ParticleUtils.particleAlmostWhiteColor
        c?.pageBackgroundImage = nil
        
        c?.normalTextColor = ParticleUtils.particleDarkGrayColor// UIColor.whiteColor()
        c?.linkTextColor = ParticleUtils.particleDarkGrayColor

        c?.modeButtonName = "SETUP button"
        
        c?.elementTextColor = UIColor.white//(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 1.0) //(patternImage: UIImage(named: "imgOrangeGradient")!)
        c?.elementBackgroundColor = ParticleUtils.particleCyanColor
        c?.brandImage = UIImage(named: "particle-horizontal-head")
        c?.brandImageBackgroundColor = .clear
        c?.brandImageBackgroundImage = UIImage(named: "imgTrianglifyHeader")

        c?.tintSetupImages = false
        c?.instructionalVideoFilename = "photon_wifi.mp4"
        c?.allowPasswordManager = true
        c?.lightStatusAndNavBar = true
        c?.disableLogOutOption = true
        
    }

    func invokeMeshDeviceSetup() {
        self.present(MeshSetupFlowUIManager.loadedViewController(), animated: true)
    }
    
    
    func invokePhotonDeviceSetup()
    {
//        let dsc = ParticleSetupCustomization.sharedInstance()
//        dsc.brandImage = UIImage(named: "setup-device-header")
        
        self.customizeSetupForSetupFlow()
        if let vc = ParticleSetupMainController(setupOnly: !ParticleCloud.sharedInstance().isAuthenticated)
        {
            SEGAnalytics.shared().track("Tinker_PhotonSetupInvoked")
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    func showParticleCoreAppPopUp()
    {
        SEGAnalytics.shared().track("Tinker_UserWantsToSetupACore")
        
        let dialog = ZAlertView(title: "Core setup", message: "Setting up a Core requires the legacy Particle Core app. Do you want to install/open it now?", isOkButtonLeft: true, okButtonText: "Yes", cancelButtonText: "No",
                                okButtonHandler: { alertView in
                                    alertView.dismiss()
                                    let particleCoreAppStoreLink = "itms://itunes.apple.com/us/app/apple-store/id760157884?mt=8";
                                    SEGAnalytics.shared().track("Tinker_SendUserToOldParticleCoreApp")
                                    UIApplication.shared.openURL(URL(string: particleCoreAppStoreLink)!)
                                    
            },
                                cancelButtonHandler: { alertView in
                                    alertView.dismiss()
            }
        )

        
        
        dialog.show()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Selected indexPath: %i", withParameters: getVaList([indexPath.row]))


        RMessage.dismissActiveNotification()
        tableView.deselectRow(at: indexPath, animated: true)
        let device = self.devices[(indexPath as NSIndexPath).row]

        tableView.deselectRow(at: indexPath, animated: false)
        
        //                println("Tapped on \(self.devices[indexPath.row].description)")
        if devices[(indexPath as NSIndexPath).row].isFlashing
        {
            RMessage.showNotification(withTitle: "Device is being flashed", subtitle: "Device is currently being flashed, please wait for the process to finish.", type: .warning, customTypeName: nil, callback: nil)
        } else {
            self.selectedDevice = self.devices[indexPath.row]
            self.performSegue(withIdentifier: "deviceInspector", sender: indexPath)
        }
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    @IBAction func consolleTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "logList", sender: self)
    }
    

    @IBAction func logoutButtonTapped(_ sender: UIButton) {

        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Logout tapped", withParameters: getVaList([]))
        //this method is can be triggered by Log In button therefore we have to have else clause
        if (ParticleCloud.sharedInstance().isAuthenticated) {
            let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Log out", style: .default) { action in
                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Logout confirmed", withParameters: getVaList([]))
                self.logout()
            })
            self.present(alert, animated: true)
        } else if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }


    private func logout() {
        ParticleCloud.sharedInstance().logout()

        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }

}
