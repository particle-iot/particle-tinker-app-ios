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

    internal var items: [String] = ["trashy_fox", "agent_orange", "test_core2"]
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var masterCell : UITableViewCell?
        
        
        if indexPath.row < self.devices.count
        {
//            println("DeviceTableViewCell : \(indexPath.row) / \(self.items.count)")
            var cell:DeviceTableViewCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("device_cell") as! DeviceTableViewCell
            if let name = self.devices[indexPath.row].name
            {
                cell.deviceNameLabel.text = name
            }
            else
            {
                cell.deviceNameLabel.text = "<Empty>"
            }
            
//            cell.deviceIDLabel.text = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
//            cell.deviceIDLabel.text = cell.deviceIDLabel.text!.substringToIndex(advance(cell.deviceIDLabel.text!.startIndex,24))
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
            println("NewDeviceTableViewCell : \(indexPath.row) / \(self.items.count)")
            masterCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("new_device_cell") as? UITableViewCell
            
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
            // TODO: show some error message
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
                    // TODO: show some offline / not running tinker error
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
        //...
    }
    
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        SparkCloud.sharedInstance().logout()
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }

    }
    
    

    
}
