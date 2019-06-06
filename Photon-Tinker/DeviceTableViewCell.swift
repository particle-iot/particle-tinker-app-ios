//
//  DeviceTableViewCell.swift
//  Photon-Tinker
//
//  Created by Ido on 4/17/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit
import QuartzCore

internal class DeviceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.deviceCellBackgroundView.layer.cornerRadius = 6.0
        self.deviceCellBackgroundView.layer.masksToBounds = true

    }

    @IBOutlet weak var deviceCellBackgroundView: UIView!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceStateLabel: UILabel!
}
