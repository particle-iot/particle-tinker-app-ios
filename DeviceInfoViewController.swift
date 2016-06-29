//
//  DeviceInfoViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 5/10/16.
//  Copyright © 2016 Particle. All rights reserved.
//

import Foundation

class DeviceInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var deviceIPAddressLabel: UILabel!
    @IBOutlet weak var deviceStateLabel: UILabel!
//    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var lastHeardLabel: UILabel!
    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var deviceIDLabel: UILabel!
    
    @IBAction func copyDeviceID(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = self.device?.id
        TSMessage.showNotificationWithTitle("Copied", subtitle: "Device ID was copied to the clipboard", type: .Success)
    }
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var IMEITitleLabel: UILabel!
    @IBOutlet weak var IMEILabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!

    @IBOutlet weak var ICCIDTitleLabel: UILabel!
    @IBOutlet weak var ICCIDLabel: UILabel!
    
    @IBOutlet weak var deviceDataTableView: UITableView!
    
    @IBOutlet weak var deviceImageView: UIImageView!
    
    @IBOutlet weak var copyDeviceIccidButton: UIButton!
    @IBOutlet weak var dataUsageTitleLabel: UILabel!
    @IBOutlet weak var dataUsageLabel: UILabel!
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Standard colors
    let sparkLightGrayColor = UIColor(white: 0.968, alpha: 1.0)
    let sparkDarkGrayColor = UIColor(white: 0.466, alpha: 1.0)
    let sparkCyanColor = UIColor(red: 0, green: 0.654, blue: 0.901, alpha: 1.0)
    
    
    var deviceListViewController : DeviceListViewController?
    
    var device : SparkDevice?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.darkGrayColor()
        let backgroundImage = UIImageView(image: UIImage(named: "imgTrianglifyBackgroundBlue")!)
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
        backgroundImage.alpha = 0.75
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        self.deviceDataTableView.allowsMultipleSelection = true
        self.deviceDataTableView.delegate = self
        self.deviceDataTableView.dataSource = self

        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var variablesList : [String]?
    var signalling : Bool = false
    
    @IBAction func copyDeviceIccid(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = self.device?.lastIccid
        TSMessage.showNotificationWithTitle("Copied", subtitle: "Device SIM ICCID was copied to the clipboard", type: .Success)

    }
    

    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = sparkLightGrayColor
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGrayColor()// sparkDarkGrayColor
    }
    
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        // heading
        let actionMenu = UIAlertController(title: "Device action", message: nil, preferredStyle: .ActionSheet)
        
        
        // 1
        let refreshAction = UIAlertAction(title: "Refresh data", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.device?.refresh({ (err: NSError?) in
                
                // test what happens when device goes offline and refresh is triggered
                if (err == nil) {
                    self.updateDeviceInfoDisplay()
                }
            })

        })
        refreshAction.setValue(UIImage(named: "imgLoop"), forKey: "image")
        
        // 2
        let signalAction = UIAlertAction(title: signalling ? "Stop Signal" : "Signal", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.signalling = !self.signalling
            self.device?.signal(self.signalling, completion: nil)

        })
        signalAction.setValue(UIImage(named: "imgLedSignal"), forKey: "image")
        
        // 3
        let reflashAction = UIAlertAction(title: "Reflash Tinker", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            /// WIP
            self.reflashTinker()
        })
        reflashAction.setValue(UIImage(named: "imgReflash"), forKey: "image")
        

        let editNameAction = UIAlertAction(title: "Edit Name", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            /// WIP
        })
        editNameAction.setValue(UIImage(named: "imgPencil"), forKey: "image")
        
        let docsAction = UIAlertAction(title: "Support/Documentation", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("help", sender: self);
            
        })
        docsAction.setValue(UIImage(named: "imgQuestion"), forKey: "image")

        
        
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
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "help" {
//            let navController = segue.destinationViewController as! UINavigationController;
//            let docsVC = navController.viewControllers[0] as! DocsTableViewController
//            docsVC.device = self.device
            
        }
        

    }
    
    @IBOutlet weak var tableVerticalPositionContraint: NSLayoutConstraint!
    @IBAction func editDeviceName(sender: AnyObject) {
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // auto read all variables
        var index : NSIndexPath
        
        for i in 0..<self.tableView(self.deviceDataTableView, numberOfRowsInSection: 1) {
            index = NSIndexPath(forRow: i, inSection: 1)
            let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.cellForRowAtIndexPath(index) as? DeviceVariableTableViewCell
            
            if cell!.device == nil {
                return
            } else {
                cell?.readButtonTapped(self)
            }
        }
    }
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    
    private func updateDeviceInfoDisplay() {
        if self.device!.type != .Electron {
            self.ICCIDTitleLabel.hidden = true
            self.IMEITitleLabel.hidden = true
            self.IMEILabel.hidden = true
            self.ICCIDLabel.hidden = true
            self.dataUsageLabel.hidden = true
            self.dataUsageTitleLabel.hidden = true
            self.copyDeviceIccidButton.hidden = true
            
            // try to decrease size for auto layout table to expand up
            tableVerticalPositionContraint.constant = -32;
            
        } else {
            self.IMEILabel.text = self.device?.imei
            self.ICCIDLabel.text = self.device?.lastIccid
//            tableViewTopConstraint.constant = 48;
            
        }
        
        self.deviceDataTableView.hidden = !self.device!.connected
        
        self.deviceIPAddressLabel.text = self.device?.lastIPAdress
        self.lastHeardLabel.text = self.device?.lastHeard?.description.stringByReplacingOccurrencesOfString("+0000", withString: "") // process
        if let name = self.device?.name {
            self.deviceNameLabel.text = name
        } else {
        }
        
        self.deviceIDLabel.text = self.device?.id
        self.connectionLabel.text = (self.device!.type == .Electron) ? "Cellular" : "Wi-Fi"
        
        let deviceStateInfo = self.deviceListViewController!.getDeviceStateDescription(self.device)
        self.deviceStateLabel.text = deviceStateInfo
        self.deviceStateImageView.image = UIImage(named: "imgCircle")
        
        self.deviceListViewController?.animateOnlineIndicatorImageView(self.deviceStateImageView, online: self.device!.connected)
        
        let deviceInfo = self.deviceListViewController!.getDeviceTypeAndImage(self.device)
        self.deviceImageView.image = deviceInfo.deviceImage
        self.deviceTypeLabel.text = " "+deviceInfo.deviceType+" "
        self.deviceTypeLabel.backgroundColor = UIColor(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 0.72)
        
        self.deviceTypeLabel.textColor = UIColor(white: 0.99, alpha: 1.0)
        self.deviceTypeLabel.layer.cornerRadius = 4
        self.deviceTypeLabel.layer.masksToBounds = true

        
        self.variablesList = [String]()
        for (key, value) in (self.device?.variables)! {
            var varType : String = ""
            switch value {
            case "int32" :
                varType = "Integer"
            case "float" :
                varType = "Float"
            default:
                varType = "String"
            }
            self.variablesList?.append(String("\(key),\(varType)"))
        }
        
//        self.dataUsageLabel.hidden = true
        self.device?.getCurrentDataUsage({ (dataUsed: Float, err: NSError?) in
            if let _ = err {
//                self.dataUsageTitleLabel.hidden = true
                self.dataUsageLabel.text = "No data"
            } else {
                self.dataUsageLabel.hidden = false
                let ud = NSString(format: "%.3f", dataUsed)
                self.dataUsageLabel.text = "\(ud) MBs"
            }
        })
        
        self.deviceDataTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        // move to refresh function
        
        self.updateDeviceInfoDisplay()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        switch section {
        case 0 : title = "FUNCTIONS"
        case 1 : title = "VARIABLES"
        default : title = "EVENTS"
        }
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return max(self.device!.functions.count,1)
        case 1 : return max(self.device!.variables.count,1)
        default : return 1; 
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var masterCell : UITableViewCell?
        var masterCell : UITableViewCell?
//        var selected : Bool = false
//        
//        if let selectedIndexPaths = tableView.indexPathsForSelectedRows where selectedIndexPaths.contains(indexPath) {
//            selected = true
//        }
//        
        
        
        switch indexPath.section {
        case 0 : // Functions
            let cell : DeviceFunctionTableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("functionCell") as? DeviceFunctionTableViewCell
            if (self.device!.functions.count == 0) {
                // something else
                cell!.functionName = ""
            } else {
                cell!.functionName = self.device?.functions[indexPath.row]
                cell!.device = self.device
            }
            
//            cell?.centerFunctionNameLayoutConstraint.constant = selected ? 0 : -20

            masterCell = cell
        
        case 1 :
            let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("variableCell") as? DeviceVariableTableViewCell
            
            if (self.device!.variables.count == 0) {
                cell!.variableName = ""
            } else {
                let varArr =  self.variablesList![indexPath.row].characters.split{$0 == ","}.map(String.init)
                //
                cell!.variableType = varArr[1]
                cell!.variableName = varArr[0]
                cell!.device = self.device
            }
//            cell?.variableNameCenterLayoutConstraint.constant = selected ? 0 : -20
           
            masterCell = cell;
            
        default :
            // events WIP
            // temp
            
            let cell : UITableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("infoCell")
            
            cell?.accessoryType = .DisclosureIndicator
            cell?.textLabel?.text = "Device Event Stream"
            
            masterCell = cell;
            
            
            
            
        }
        
        masterCell?.selectionStyle = .None

        //        masterCell?.selectedBackgroundView
//        masterCell?.select
       

//        if (selected) {
//            masterCell?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
//        } else {
//            masterCell?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
//        }

        return masterCell!
        
        
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows where selectedIndexPaths.contains(indexPath) {
            return 80.0 // Expanded height
        }
        
        return 44.0 // Normal height
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : DeviceDataTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceDataTableViewCell
        if cell.device == nil || indexPath.section > 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            
//            let duration = 0.25
//            let delay = 0.0
//            let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceFunctionTableViewCell
            let halfRotation = CGFloat(M_PI)
            
            UIView.animateWithDuration(0.3, animations: {
                // animating `transform` allows us to change 2D geometry of the object
                // like `scale`, `rotation` or `translate`
                cellAnim.argumentsButton.transform = CGAffineTransformMakeRotation(halfRotation)
            })
            
            updateTableView()
        }
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : DeviceDataTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceDataTableViewCell
        if cell.device != nil && indexPath.section == 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)

            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceFunctionTableViewCell
            
            UIView.animateWithDuration(0.3, animations: {
                // animating `transform` allows us to change 2D geometry of the object
                // like `scale`, `rotation` or `translate`
                cellAnim.argumentsButton.transform = CGAffineTransformIdentity//CGAffineTransformMakeRotation(halfRotation)
            })
            
            
        }
        updateTableView()
        view.endEditing(true)
    }
    
    private func updateTableView() {
        self.deviceDataTableView.beginUpdates()
        self.deviceDataTableView.endUpdates()
    }
    
    
//    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView!
//    {
//        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
//        headerView.backgroundColor = UIColor.clearColor()

        
//        
//        UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
//        tempLabel.backgroundColor=[UIColor clearColor];
//        tempLabel.shadowColor = [UIColor blackColor];
//        tempLabel.shadowOffset = CGSizeMake(0,2);
//        tempLabel.textColor = [UIColor redColor]; //here you can change the text color of header.
//        tempLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSizeForHeaders];
//        tempLabel.font = [UIFont boldSystemFontOfSize:fontSizeForHeaders];
//        tempLabel.text=@"Header Text";
//        
//        [tempView addSubview:tempLabel];
//        
//        [tempLabel release];
//        return tempView;
        
//        
//        return headerView
//    }
//    
    
    
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


