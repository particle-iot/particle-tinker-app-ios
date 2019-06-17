//
// Created by Raimundas Sakalauskas on 2019-06-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInfoSliderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var valueLabel: MeshLabel!
    @IBOutlet weak var iconImage: DeviceTypeIcon!

    func setup(title: String, value:Any) {

        self.titleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        self.valueLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        self.titleLabel.text = title
        if let type = value as? ParticleDeviceType {
            self.iconImage.isHidden = false
            self.valueLabel.isHidden = false

            self.iconImage.setDeviceType(type)
            self.valueLabel.text = type.description
        } else if let text = value as? String {
            self.iconImage.isHidden = true
            self.valueLabel.isHidden = false

            self.valueLabel.text = text
        } else {
            self.iconImage.isHidden = true
            self.valueLabel.isHidden = true
        }
    }
}
