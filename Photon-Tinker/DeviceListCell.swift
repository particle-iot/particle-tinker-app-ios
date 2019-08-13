//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 spark. All rights reserved.
//


import UIKit
import QuartzCore

internal class DeviceListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var lastHeardLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!
    
    private var device: ParticleDevice!
    
    func setup(device: ParticleDevice) {
        self.device = device

        self.nameLabel.text = device.getName()

        self.typeLabel.textColor = device.type.getIconColor()
        self.typeLabel.layer.borderColor = device.type.getIconColor().cgColor
        self.typeLabel.text = device.type.description

        self.lastHeardLabel.text = device.lastHeard?.tinkerFormattedString() ?? "Unknown"

        ParticleUtils.animateOnlineIndicatorImageView(deviceStateImageView, online: device.connected, flashing:device.isFlashing)
    }


    override func awakeFromNib() {
        super.awakeFromNib()

        self.typeLabel.layer.cornerRadius = 12
        self.typeLabel.layer.masksToBounds = true
        self.typeLabel.layer.borderWidth = 1
    }
}
