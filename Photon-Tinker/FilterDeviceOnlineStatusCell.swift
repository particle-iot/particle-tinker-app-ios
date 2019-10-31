//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 Particle. All rights reserved.
//


import UIKit
import QuartzCore

internal class FilterDeviceOnlineStatusCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!

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

    func setup(option: DeviceOnlineStatusOptions) {
        self.titleLabel.text = option.description
        self.deviceStateImageView.image = UIImage(named: "ImgCircle")!.withRenderingMode(.alwaysTemplate)

        if (option == .online) {
            self.deviceStateImageView.tintColor = ParticleStyle.ButtonColor
        } else {
            self.deviceStateImageView.tintColor = ParticleStyle.FilterBorderColor
        }
    }

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue

            self.layer.borderWidth = newValue ? 2 : 1
            self.layer.borderColor = newValue ? ParticleStyle.ButtonColor.cgColor : ParticleStyle.FilterBorderColor.cgColor
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
