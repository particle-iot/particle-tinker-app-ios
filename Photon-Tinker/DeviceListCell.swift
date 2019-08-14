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
    var cellHighlight: UIView!
    
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

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.cellHighlight.alpha = highlighted ? 1 : 0
            }
        } else {
            self.cellHighlight.alpha = highlighted ? 1 : 0
        }
    }
}
