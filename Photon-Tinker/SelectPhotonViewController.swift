//
//  SelectPhotonViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class SelectPhotonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SparkSetupMainControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        var backgroundImage = UIImageView(image: UIImage(named: "imgBackgroundBlue")!)
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        
        // Do any additional setup after loading the view.
    }

    var devices : [SparkDevice] = []
    var selectedDevice : SparkDevice? = nil
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var photonSelectionTableView: UITableView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        self.loadDevices()
    }
    
    
    func loadDevices()
    {
        var hud : MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .CustomView//.Indeterminate
        hud.animationType = .ZoomIn
        hud.labelText = "Loading"
        
        // prepare spinner view for first time populating of devices into table
        var spinnerView : UIImageView = UIImageView(image: UIImage(named: "imgSpinner"))
        spinnerView.frame = CGRectMake(0, 0, 37, 37);
        spinnerView.contentMode = .ScaleToFill
        var rotation = CABasicAnimation(keyPath:"transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2*M_PI
        rotation.duration = 1.0;
        rotation.repeatCount = 1000; // Repeat
        spinnerView.layer.addAnimation(rotation,forKey:"Spin")
    
        hud.customView = spinnerView

        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            
            SparkCloud.sharedInstance().getDevices({ (devices:[AnyObject]!, err:NSError!) -> Void in
                if (err != nil)
                {
                    println("error listing devices for user \(SparkCloud.sharedInstance().loggedInUsername)")
                    println(err?.description)
                    TSMessage.showNotificationWithTitle("Error", subtitle: "Error loading devices, please check internet connection.", type: .Error)
                }
                else
                {
                    self.devices = devices as! [SparkDevice]
                    dispatch_async(dispatch_get_main_queue()) {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.photonSelectionTableView.reloadData()
                    }
                    
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var masterCell : UITableViewCell?
        
        
        if indexPath.row < self.devices.count
        {
            var cell:DeviceTableViewCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("device_cell") as! DeviceTableViewCell
            if let name = self.devices[indexPath.row].name
            {
                cell.deviceNameLabel.text = name
            }
            else
            {
                cell.deviceNameLabel.text = "<Empty>"
            }
            
            cell.deviceIDLabel.text = devices[indexPath.row].id
            
            let online = self.devices[indexPath.row].connected
            switch online
            {
                case true :
                    cell.deviceStateLabel.text = "Online"
                    cell.deviceStateImageView.image = UIImage(named: "imgGreenCircle")
                
                default :
                    cell.deviceStateLabel.text = "Offline"
                    cell.deviceStateImageView.image = UIImage(named: "imgRedCircle")

            }
            
            cell.deviceTypeLabel.text = "Photon"
            
            masterCell = cell
        }
        else
        {
            masterCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("new_device_cell") as? UITableViewCell
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
    
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        if result == .Success
        {
            self.photonSelectionTableView.reloadData()
        }
        else
        {
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Device setup did not complete, new device was not added.", type: .Warning)
        }
    }
    
    func invokeDeviceSetup()
    {
        if let vc = SparkSetupMainController()
        {
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }

    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if self.devices.count == 0
        {
            self.invokeDeviceSetup()
        }
        else
        {
            
            switch indexPath.row
            {
            case 0...self.devices.count-1 :
                if self.devices[indexPath.row].connected
                {
                    self.selectedDevice = self.devices[indexPath.row]
                    self.performSegueWithIdentifier("tinker", sender: self)
                }
                else
                {
                    // TODO: add "not running tinker, do you want to flash?"
                    TSMessage.showNotificationWithTitle("Device offline", subtitle: "This device is offline, please turn it on and refresh in order to Tinker with it.", type: .Error)
                }
            case self.devices.count :
                self.invokeDeviceSetup()
            default :
                break
        }
        }
    
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tinker"
        {
            if let vc = segue.destinationViewController as? SPKTinkerViewController
            {
                vc.device = self.selectedDevice!
            }
        }
    }
    
    @IBAction func refreshButtonTapped(sender: UIButton) {
        self.photonSelectionTableView.reloadData()
        
        
        
    }
    
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        SparkCloud.sharedInstance().logout()
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }

    }
    
    

    
}
