//
// Created by Raimundas Sakalauskas on 2019-06-10.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceTypeLabel: ParticleLabel {
    private var deviceType: ParticleDeviceType?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.internalSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.internalSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.internalSetup()
    }

    func setDeviceType(_ type: ParticleDeviceType) {
        self.deviceType = type

        self.textColor = type.getIconColor()
        self.layer.borderColor = type.getIconColor().cgColor
        self.text = type.description
    }

    func internalSetup() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.textAlignment = .center
        self.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: .white)

        NSLayoutConstraint.activate(
            [
                self.widthAnchor.constraint(equalToConstant: 80),
                self.heightAnchor.constraint(equalToConstant: 24)
            ]
        )
    }
}
