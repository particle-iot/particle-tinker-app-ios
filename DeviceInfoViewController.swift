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
    }
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var IMEITitleLabel: UILabel!
    @IBOutlet weak var IMEILabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!

    @IBOutlet weak var ICCIDTitleLabel: UILabel!
    @IBOutlet weak var ICCIDLabel: UILabel!
    
    @IBOutlet weak var deviceDataTableView: UITableView!
    
    @IBOutlet weak var deviceImageView: UIImageView!
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    var deviceListViewController : DeviceListViewController?
    
    var device : SparkDevice?
    
    override func viewDidLoad() {
        let backgroundImage = UIImageView(image: UIImage(named: "imgTrianglifyBackgroundBlue")!)
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        self.deviceDataTableView.delegate = self
        self.deviceDataTableView.dataSource = self

    }
    
    var variablesList : [String]?
    
    override func viewWillAppear(animated: Bool) {
        if self.device!.type != .Electron {
            self.ICCIDTitleLabel.hidden = true
            self.IMEITitleLabel.hidden = true
            self.IMEILabel.hidden = true
            self.ICCIDLabel.hidden = true
        } else {
            self.IMEILabel.text = self.device?.imei
            self.ICCIDLabel.text = self.device?.lastIccid
        }
        
        self.deviceIPAddressLabel.text = self.device?.lastIPAdress
        self.lastHeardLabel.text = self.device?.lastHeard?.description.stringByReplacingOccurrencesOfString("+0000", withString: "") // process
        self.deviceNameLabel.text = self.device?.name
        self.deviceIDLabel.text = self.device?.id
        self.connectionLabel.text = (self.device!.type == .Electron) ? "Cellular" : "Wi-Fi"

        let deviceStateInfo = self.deviceListViewController!.getDeviceStateDescAndImage(self.device)
        self.deviceStateLabel.text = deviceStateInfo.deviceStateText
        self.deviceStateImageView.image = deviceStateInfo.deviceStateImage

        let deviceInfo = self.deviceListViewController!.getDeviceTypeAndImage(self.device)
        self.deviceImageView.image = deviceInfo.deviceImage
        self.deviceTypeLabel.text = deviceInfo.deviceType
        
        self.variablesList = [String]()
        for (key, value) in (self.device?.variables)! {
            self.variablesList?.append(String("\(key) (\(value))"))
        }
    
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        switch section {
        case 0 : title = "Functions"
        case 1 : title = "Variables"
        default : title = "Events"
        }
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return self.device!.functions.count
        case 1 : return self.device!.variables.count
        default : return 1;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var masterCell : UITableViewCell?
        
        let cell : UITableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("infoCell")
        
        switch indexPath.section {
        case 0 : // Functions
            cell!.textLabel?.text = self.device?.functions[indexPath.row]
        case 1 :
            cell!.textLabel?.text = self.variablesList![indexPath.row]
        default :
            cell!.textLabel?.text = "Tap for events stream"
            
            
        }
        
        return cell!
        
        
        
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
    
    
    
    
}