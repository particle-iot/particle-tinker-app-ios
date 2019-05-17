//
//  DeviceListViewController.swift
//  Photon-Tinker
//
//  Copyright (c) 2019 particle. All rights reserved.
//

import UIKit
import QuartzCore


class DeviceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParticleSetupMainControllerDelegate, ParticleDeviceDelegate, Fadeable {

    @IBOutlet weak var setupNewDeviceButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noDevicesLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var isBusy: Bool = false
    var viewsToFade: [UIView]? = nil

    var devices : [ParticleDevice] = []
    var refreshControlAdded : Bool = false

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @objc func appDidBecomeActive(_ sender : AnyObject) {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewsToFade = [self.tableView, self.moreButton, self.setupNewDeviceButton]

        if ParticleCloud.sharedInstance().isAuthenticated {
            self.addRefreshControl()
            self.fade(animated: false)
            self.noDevicesLabel.isHidden = true
        } else {
            self.noDevicesLabel.isHidden = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if ParticleCloud.sharedInstance().isAuthenticated {
            self.loadDevices()
        } else {
            self.showTutorial()
        }

        SEGAnalytics.shared().track("Tinker_DeviceListScreenActivity")
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }




    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceInspector" {
            if let vc = segue.destination as? DeviceInspectorViewController {
                let device = sender as! ParticleDevice
                vc.setup(device: device)

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Segue into device inspector - device: %@", withParameters: getVaList(["\(device)"]))
                SEGAnalytics.shared().track("Tinker_SegueToDeviceInspector", properties: ["device": device.type.description])
            }
        }
    }

    func loadDevices()
    {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices started", withParameters: getVaList([]))

        DispatchQueue.global().async {
            ParticleCloud.sharedInstance().getDevices({ (devices:[ParticleDevice]?, error:Error?) -> Void in

                self.handleGetDevicesResponse(devices, error: error)

                DispatchQueue.main.async { [weak self] () -> () in
                    if let self = self {
                        self.resume(animated: true)
                        self.showTutorial()
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
            self.devices = []

            if (e as NSError).code == 401 {
                self.logout()
            } else {
                ParticleLogger.logError(NSStringFromClass(type(of: self)), format: "Load devices error", withParameters: getVaList([]))
                RMessage.showNotification(withTitle: "Error", subtitle: "Error loading devices, please check your internet connection.", type: .error, customTypeName: nil, callback: nil)
            }

            DispatchQueue.main.async {
                self.noDevicesLabel.isHidden = false
                self.tableView.reloadData()
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

                sortDevices()

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed. Device count: %i", withParameters: getVaList([self.devices.count]))
                ParticleLogger.logDebug(NSStringFromClass(type(of: self)), format: "Devices: %@", withParameters: getVaList([self.devices]))

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.devices = []

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed. Device count: %i", withParameters: getVaList([self.devices.count]))
                ParticleLogger.logDebug(NSStringFromClass(type(of: self)), format: "Devices: %@", withParameters: getVaList([self.devices]))

                DispatchQueue.main.async {
                    self.noDevicesLabel.isHidden = false
                    self.setupNewDeviceButtonTapped(self.setupNewDeviceButton)
                    self.tableView.reloadData()
                }
            }

        }
    }

    private func sortDevices() {
        self.devices.sort(by: { (firstDevice:ParticleDevice, secondDevice:ParticleDevice) -> Bool in
            if (firstDevice.connected != secondDevice.connected) {
                return firstDevice.connected == true
            } else {
                var nameA = firstDevice.name ?? " "
                var nameB = secondDevice.name ?? " "
                return nameA.lowercased() < nameB.lowercased()
            }
        })
    }

    func addRefreshControl()
    {
        self.tableView.addPullToRefresh(withPullText: "Pull To Refresh", refreshingText: "Refreshing Devices") { () -> Void in
            weak var weakSelf = self
            ParticleCloud.sharedInstance().getDevices() { (devices:[ParticleDevice]?, error: Error?) -> Void in
                weakSelf?.handleGetDevicesResponse(devices, error: error)
                weakSelf?.tableView.finishLoading()
            }
        }
    }


    func invokeElectronSetup() {
        SEGAnalytics.shared().track("Tinker_ElectronSetupInvoked")

        let esVC : ElectronSetupViewController = self.storyboard!.instantiateViewController(withIdentifier: "electronSetup") as! ElectronSetupViewController
        self.present(esVC, animated: true, completion: nil)
    }

    func invokeMeshDeviceSetup() {
        self.present(MeshSetupFlowUIManager.loadedViewController(), animated: true)
    }


    func invokePhotonDeviceSetup()
    {
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

        var alert = UIAlertController(title: "Core setup", message: "Setting up a Core requires the legacy Particle Core app. Do you want to install/open it now?", preferredStyle: .alert) 

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
            let particleCoreAppStoreLink = "itms://itunes.apple.com/us/app/apple-store/id760157884?mt=8";
            SEGAnalytics.shared().track("Tinker_SendUserToOldParticleCoreApp")
            UIApplication.shared.openURL(URL(string: particleCoreAppStoreLink)!)
        })

        self.present(alert, animated: true)
    }



    private func logout() {
        ParticleCloud.sharedInstance().logout()

        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }


    func showTutorial() {
       if ParticleUtils.shouldDisplayTutorialForViewController(self) {
    
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if self.navigationController?.visibleViewController == self {


                    if (ParticleCloud.sharedInstance().isAuthenticated) {
                        // 2
                        var tutorial = YCTutorialBox(headline: "Setup a new device", withHelpText: "Tap the plus button to set up a new Photon or Electron device you wish to add to your account")
                        tutorial?.showAndFocus(self.setupNewDeviceButton)

                        // 1
                        let firstDeviceCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                        tutorial = YCTutorialBox(headline: "Your devices", withHelpText: "See and manage your devices.\n\nOnline devices have their indicator 'breathing' cyan, offline ones are gray.\n\nTap a device to enter Tinker or Device Inspector mode, device must run Tinker firmware to enter Tinker mode.\n\nSwipe left to remove a device from your account.\n\nPull down to refresh your list.")
                        tutorial?.showAndFocus(firstDeviceCell)
                    } else {
                        // 2
                        var tutorial = YCTutorialBox(headline: "Setup a new device", withHelpText: "Tap the plus button to set up a new wifi credentials for your Photon device")
                        tutorial?.showAndFocus(self.setupNewDeviceButton)
                    }
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
                
            }
        }
    }
    
    
    

    
    
    
    









    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var masterCell : UITableViewCell?
        
        if (indexPath as NSIndexPath).row < self.devices.count
        {
            let cell:DeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "device_cell") as! DeviceTableViewCell
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

            cell.deviceStateLabel.text = ""
            
            ParticleUtils.animateOnlineIndicatorImageView(cell.deviceStateImageView, online: self.devices[(indexPath as NSIndexPath).row].connected, flashing:self.devices[(indexPath as NSIndexPath).row].isFlashing)
            
            masterCell = cell
        }
        return masterCell!
    }
    
    
    func particleDevice(_ device: ParticleDevice, didReceive event: ParticleDeviceSystemEvent) {
        self.sortDevices()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        NotificationCenter.default.post(name: Notification.Name.ParticleDeviceSystemEvent, object: nil, userInfo: [
            "device": device,
            "event": event
        ])
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
                        self.tableView.reloadData()
                    }
                }

                self.devices.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                let delayTime = DispatchTime.now() + .milliseconds(250)

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




    
    func showSetupSuccessMessageAndReload() {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Setup success message and reloading table view", withParameters: getVaList([]))

        if (self.devices.count <= 1) {
            RMessage.showNotification(withTitle: "Success", subtitle: "Nice, you've successfully set up your first Particle! You'll be receiving a welcome email with helpful tips and links to resources. Start developing by going to https://build.particle.io/ on your computer, or stay here and enjoy the magic of Tinker.", type: .success, customTypeName: nil, callback: nil)
        } else {
            RMessage.showNotification(withTitle: "Success", subtitle: "You successfully added a new device to your account.", type: .success, customTypeName: nil, callback: nil)
        }

        self.tableView.reloadData()

    }
    
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!) {
        if result == .success
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup ended", withParameters: getVaList([]))
            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"success"])
            
            if let deviceAdded = device
            {
                if (deviceAdded.name == nil) // might be the setup naming BUG here
                {
                    print("! null name device detected"); //@@@
                    
                    let deviceName = MeshSetupStrings.getRandomDeviceName()
                    deviceAdded.rename(deviceName, completion: { (error : Error?) -> Void in
                        if let _ = error
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
                self.tableView.reloadData()
            }
        }
        else if result == .successNotClaimed
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "You successfully setup the device Wi-Fi credentials.", withParameters: getVaList([]))

            RMessage.showNotification(withTitle: "Success", subtitle: "You successfully setup the device Wi-Fi credentials. Verify its LED is breathing cyan.", type: .success, customTypeName: nil, callback: nil)
            self.tableView.reloadData()
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
        
        c?.pageBackgroundColor = UIColor(rgb: 0xF0F0F0)
        c?.pageBackgroundImage = nil
        
        c?.normalTextColor = ParticleUtils.particleDarkGrayColor
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


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Selected indexPath: %i", withParameters: getVaList([indexPath.row]))


        RMessage.dismissActiveNotification()
        tableView.deselectRow(at: indexPath, animated: true)


        let device = self.devices[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: false)

        self.fade(animated: true)

        let selectedDevice = self.devices[indexPath.row]
        selectedDevice.refresh { [weak self] error in
            if let self = self {
                self.resume(animated: true)

                if let error = error {
                    RMessage.showNotification(withTitle: "Error", subtitle: "Error getting information from Particle Cloud", type: .error, customTypeName: nil, callback: nil)
                } else {
                    self.performSegue(withIdentifier: "deviceInspector", sender: selectedDevice)
                }
            }
        }
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }


    @IBAction func setupNewDeviceButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Setup up a new device", message: nil, preferredStyle: .actionSheet)

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: "Argon / Boron / Xenon", style: .default) { action in
                if (ParticleCloud.sharedInstance().isAuthenticated) {
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Mesh setup started", withParameters: getVaList([]))
                    self.invokeMeshDeviceSetup()
                } else {
                    RMessage.showNotification(withTitle: "Authentication", subtitle: "You must be logged to your Particle account in to setup an Argon / Boron / Xenon ", type: .error, customTypeName: nil, callback: nil)
                }
            })
        }


        alert.addAction(UIAlertAction(title: "Photon", style: .default) { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup started", withParameters: getVaList([]))
            self.invokePhotonDeviceSetup()
        })

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: "Electron / SIM", style: .default) { action in
                if (ParticleCloud.sharedInstance().isAuthenticated) {
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Electron setup started", withParameters: getVaList([]))
                    self.invokeElectronSetup()
                } else {
                    RMessage.showNotification(withTitle: "Authentication", subtitle: "You must be logged to your Particle account in to setup an Electron ", type: .error, customTypeName: nil, callback: nil)
                }
            })

            alert.addAction(UIAlertAction(title: "Core", style: .default) { action in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { () -> Void in
                    self.showParticleCoreAppPopUp()
                }
            })
        }


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "More tapped", withParameters: getVaList([]))

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { action in
                let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Log out", style: .default) { action in
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Logout confirmed", withParameters: getVaList([]))
                    self.logout()
                })
                self.present(alert, animated: true)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Log in", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
        }

        alert.addAction(UIAlertAction(title: "Access application logs", style: .default, handler: { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device logs selected", withParameters: getVaList([]))
            self.performSegue(withIdentifier: "logList", sender: self)    
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Cancel tapped", withParameters: getVaList([]))
        }))

        self.present(alert, animated: true)
    }

}
