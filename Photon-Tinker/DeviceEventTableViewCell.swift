//
//  DeviceEventTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 spark. All rights reserved.
//



class DeviceEventTableViewCell: DeviceDataTableViewCell {

    @IBOutlet weak var bkgView: UIView!
    
    @IBAction func copyEventButtonTapped(sender: AnyObject) {
    }
    @IBOutlet weak var eventTimeValueLabel: UILabel!
    @IBOutlet weak var eventDataValueLabel: UILabel!
    @IBOutlet weak var eventNameValueLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 4
        self.bkgView.layer.masksToBounds = true
    
    }
    
    
}
