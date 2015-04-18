//
//  DeviceTableViewCell.swift
//  Photon-Tinker
//
//  Created by Ido on 4/17/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceStateLabel: UILabel!
}

class NewDeviceTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

