//
//  SelectPhotonViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class SelectPhotonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
            cell.deviceNameLabel.text = self.devices[indexPath.row].name
            
//            cell.deviceIDLabel.text = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
//            cell.deviceIDLabel.text = cell.deviceIDLabel.text!.substringToIndex(advance(cell.deviceIDLabel.text!.startIndex,24))
            cell.deviceIDLabel.text = devices[indexPath.row].ID
            
            switch self.devices[indexPath.row].connected
            {
                case true : cell.deviceStateLabel.text = "Online"
                default : cell.deviceStateLabel.text = "Offline"
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    @IBAction func refreshButtonTapped(sender: UIButton) {
        self.photonSelectionTableView.reloadData()
        //...
    }
    
    
    @IBAction func logoutButtonTapped(sender: UIButton) {

    }

    
}
