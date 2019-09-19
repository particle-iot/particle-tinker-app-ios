//
// Created by Raimundas Sakalauskas on 2019-06-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInfoSliderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var valueLabel: ParticleLabel!

    func setup(title: String, value:Any) {
        self.titleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        self.titleLabel.text = title

        if let type = value as? ParticleDeviceType {
            self.valueLabel.isHidden = false
            (self.valueLabel as! DeviceTypeLabel).setDeviceType(type)
        } else if let text = value as? String {
            self.valueLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
            self.valueLabel.isHidden = false
            self.valueLabel.text = text
        } else {
            self.valueLabel.isHidden = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        self.selectedBackgroundView = cellHighlight
    }
}
