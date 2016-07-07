//
//  DeviceInspectorInfoViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/28/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class DeviceInspectorInfoViewController: DeviceInspectorChildViewController {

    @IBOutlet weak var deviceIccidValueLabel: UILabel!
    @IBOutlet weak var deviceIccidLabel: UILabel!
    @IBOutlet weak var deviceIpAddressValueLabel: UILabel!
    @IBOutlet weak var deviceLastHeardValueLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var deviceIdValueLabel: UILabel!
    @IBOutlet weak var deviceImeiLabel: UILabel!
    @IBOutlet weak var deviceImeiValueLabel: UILabel!
    @IBOutlet weak var dataUsageLabel: UILabel!
    @IBOutlet weak var dataUsageValueLabel: UILabel!
    
    @IBOutlet weak var copyDeviceIccidButton: UIButton!
    
    @IBAction func copyDeviceIdButtonTapped(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = self.device?.id
        TSMessage.showNotificationWithTitle("Copied", subtitle: "Device ID was copied to the clipboard", type: .Success)
    }
    
    @IBAction func copyDeviceIccidButtonTapped(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = self.device?.lastIccid
        TSMessage.showNotificationWithTitle("Copied", subtitle: "Device SIM ICCID was copied to the clipboard", type: .Success)
    }
    
    
    func updateDeviceInfoDisplay() {
        if self.device!.type != .Electron {
            self.deviceIccidLabel.hidden = true
            self.deviceIccidValueLabel.hidden = true
            
            self.deviceImeiLabel.hidden = true
            self.deviceImeiValueLabel.hidden = true
            
            self.dataUsageLabel.hidden = true
            self.dataUsageValueLabel.hidden = true
            
            self.copyDeviceIccidButton.hidden = true
            
        } else {
            self.deviceImeiValueLabel.text = self.device?.imei
            self.deviceIccidValueLabel.text = self.device?.lastIccid
        }
        
        self.deviceIpAddressValueLabel.text = self.device?.lastIPAdress
        self.deviceLastHeardValueLabel.text = self.device?.lastHeard?.timeAgoSinceNow()
        
        self.deviceIdValueLabel.text = self.device?.id
        
        let deviceTypeColor = DeviceUtils.particleCyanColor
        
        
        let deviceInfo = DeviceUtils.getDeviceTypeAndImage(self.device)
        self.deviceImageView.image = deviceInfo.deviceImage
        self.deviceTypeLabel.text = "  "+deviceInfo.deviceType+"  "
        self.deviceTypeLabel.layer.borderColor = DeviceUtils.particleCyanColor.CGColor
        self.deviceTypeLabel.layer.borderWidth = 1.0
        self.deviceTypeLabel.textColor = deviceTypeColor
        self.deviceTypeLabel.layer.cornerRadius = 4
        self.deviceTypeLabel.layer.masksToBounds = true
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            self.device?.getCurrentDataUsage({ (dataUsed: Float, err: NSError?) in
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    
                    if let _ = err {
                        self.dataUsageValueLabel.text = "No data"
                    } else {
                        let ud = NSString(format: "%.3f", dataUsed)
                        self.dataUsageValueLabel.text = "\(ud) MBs"
                    }
                }
            })
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        updateDeviceInfoDisplay()
    }
    
    
}
