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
    @IBOutlet weak var firmwareVersionLabel: UILabel!
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
    }
    
    var device : SparkDevice?
    
    
    
    
    
}