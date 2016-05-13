//
//  DeviceInfoViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 5/10/16.
//  Copyright © 2016 Particle. All rights reserved.
//

import Foundation

class DeviceInfoViewController: UIViewController, UITableViewDelegate {
    
    
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

    }
    
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

        let deviceInfo = self.deviceListViewController!.getDeviceNameAndImage(self.device)
        self.deviceImageView.image = deviceInfo.deviceImage
        self.deviceNameLabel.text = deviceInfo.deviceName

        
   
        
    }
    
    
    
    
    
}