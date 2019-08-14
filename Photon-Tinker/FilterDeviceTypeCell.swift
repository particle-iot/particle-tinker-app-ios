//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 spark. All rights reserved.
//


import UIKit
import QuartzCore

internal class FilterDeviceTypeCell: UICollectionViewCell {

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

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear

        self.cellHighlight = UIView()
        self.cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        self.cellHighlight.translatesAutoresizingMaskIntoConstraints = false
        self.cellHighlight.alpha = 0
        self.contentView.insertSubview(self.cellHighlight, at: 0)
        NSLayoutConstraint.activate(
                [
                    self.cellHighlight.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
                    self.cellHighlight.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
                    self.cellHighlight.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                    self.cellHighlight.topAnchor.constraint(equalTo: self.contentView.topAnchor)
                ]
        )
    }

    func setup(option: DeviceTypeOptions) {
        self.titleLabel.text = option.description
        self.deviceTypeImage.isHidden = false
        self.stackviewYConstraint.constant = 3

        switch option {
            case .boron:
                self.deviceTypeImage.setDeviceType(.boron)
            case .electron:
                self.deviceTypeImage.setDeviceType(.electron)
            case .argon:
                self.deviceTypeImage.setDeviceType(.argon)
            case .photon:
                self.deviceTypeImage.setDeviceType(.photon)
            case .xenon:
                self.deviceTypeImage.setDeviceType(.xenon)
            case .other:
                self.deviceTypeImage.isHidden = true
                self.stackviewYConstraint.constant = 0
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
