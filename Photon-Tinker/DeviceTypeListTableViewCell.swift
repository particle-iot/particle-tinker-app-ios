//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 spark. All rights reserved.
//


import UIKit
import QuartzCore

internal class DeviceTypeListTableViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceTypeImage: DeviceTypeIcon!
    @IBOutlet weak var stackviewYConstraint: NSLayoutConstraint!
    
    var cellHighlight: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        self.layer.borderColor = ParticleStyle.SecondaryTextColor.cgColor

        cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        cellHighlight.translatesAutoresizingMaskIntoConstraints = false
        cellHighlight.alpha = 0
        insertSubview(cellHighlight, at: 0)
        NSLayoutConstraint.activate(
                [
                    cellHighlight.leftAnchor.constraint(equalTo: self.leftAnchor),
                    cellHighlight.rightAnchor.constraint(equalTo: self.rightAnchor),
                    cellHighlight.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    cellHighlight.topAnchor.constraint(equalTo: self.topAnchor)
                ]
        )
    }

    func setup(option: DeviceTypeOptions) {
        titleLabel.text = option.description
        deviceTypeImage.isHidden = false
        stackviewYConstraint.constant = 3

        switch option {
            case .boron:
                deviceTypeImage.setDeviceType(.boron)
            case .electron:
                deviceTypeImage.setDeviceType(.electron)
            case .argon:
                deviceTypeImage.setDeviceType(.argon)
            case .photon:
                deviceTypeImage.setDeviceType(.photon)
            case .xenon:
                deviceTypeImage.setDeviceType(.xenon)
            case .other:
                deviceTypeImage.isHidden = true
                stackviewYConstraint.constant = 0
        }
    }

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue

            self.layer.borderColor = newValue ? ParticleStyle.ButtonColor.cgColor : ParticleStyle.FilterFrameColor.cgColor
        }
    }
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue

            self.cellHighlight.alpha = newValue ? 1 : 0
        }
    }


}
