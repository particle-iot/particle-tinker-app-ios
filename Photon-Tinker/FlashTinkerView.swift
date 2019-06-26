//
// Created by Raimundas Sakalauskas on 2019-05-20.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class FlashTinkerView: TinkerView, Fadeable {
    var view: UIView {
        return self
    }

    var isBusy: Bool = false
    private(set) var viewsToFade: [UIView]? = nil

    @IBOutlet weak var flashTinkerButton: ParticleButton!
    @IBOutlet weak var flashTinkerLabel: UILabel!

    override func setup(_ device: ParticleDevice) {
        self.device = device

        self.setupDeviceImage()
        
        self.flashTinkerButton.setTitle("FLASH TINKER", for: .normal)
        self.flashTinkerButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)

        viewsToFade = [self.flashTinkerButton, self.flashTinkerLabel]
    }

    override func setupDeviceImage() {
        super.setupDeviceImage()

        backgroundImageView.tintColor = UIColor(rgb: 0xD9D8D6, alpha: 0.15)
    }

}
