//
// Created by Raimundas Sakalauskas on 2019-06-10.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceTypeIcon: UIView {
    private var backgroundCircle: PieProgressView?
    private var deviceTypeLabel: ParticleLabel?

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

        self.backgroundCircle?.pieBorderColor = type.getIconColor()
        self.deviceTypeLabel?.text = type.getIconText()
    }

    func internalSetup() {
        guard self.backgroundCircle == nil else {
            return
        }

        self.backgroundColor = .clear

        self.backgroundCircle = PieProgressView(frame: .zero)
        self.backgroundCircle!.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundCircle!.progress = 1
        self.backgroundCircle!.pieFillColor = .clear
        self.backgroundCircle!.pieBorderWidth = 1
        self.backgroundCircle!.pieBorderColor = ParticleStyle.RedTextColor

        self.addSubview(self.backgroundCircle!)
        NSLayoutConstraint.activate([
            self.backgroundCircle!.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.backgroundCircle!.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backgroundCircle!.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundCircle!.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])


        self.deviceTypeLabel = ParticleLabel(frame: .zero)
        self.deviceTypeLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.deviceTypeLabel!.adjustsFontSizeToFitWidth = true
        self.deviceTypeLabel!.textAlignment = .center
        self.deviceTypeLabel!.baselineAdjustment = .alignCenters

        self.deviceTypeLabel?.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: ParticleStyle.DetailsTextColor)

        self.addSubview(self.deviceTypeLabel!)
        NSLayoutConstraint.activate([
            self.deviceTypeLabel!.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.deviceTypeLabel!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.deviceTypeLabel!.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: -8)
        ])

        if let deviceType = self.deviceType {
            self.setDeviceType(deviceType)
        }
    }
}
