//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 Particle. All rights reserved.
//


import UIKit
import QuartzCore

internal class DeviceListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: DeviceTypeLabel!
    @IBOutlet weak var lastHeardLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!
    
    private var device: ParticleDevice!
    var cellHighlight: UIView!
    
    func setup(device: ParticleDevice, searchTerm: String? = nil) {
        self.device = device

        if let searchTerm = searchTerm {
            //if device is filtered by its name
            if (device.getName().lowercased().contains(searchTerm)) {
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        let deviceName = device.getName()
                        var attributedName = NSMutableAttributedString(string: deviceName)
                        attributedName.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: (deviceName.lowercased() as NSString).range(of: searchTerm))
                        self.nameLabel.attributedText = attributedName

                        self.typeLabel.setDeviceType(device.type)
                        self.lastHeardLabel.text = device.lastHeard?.tinkerFormattedString() ?? TinkerStrings.DeviceList.Unknown

                        ParticleUtils.animateOnlineIndicatorImageView(self.deviceStateImageView, online: device.connected, flashing: device.isFlashing)
                    }
                }
            } else { //if device is filtered by some other property
                var title: String!
                var value: String!

                if device.lastIPAdress?.lowercased().contains(searchTerm) ?? false {
                    title = TinkerStrings.InfoSlider.DeviceCell.LastIPAddress
                    value = device.lastIPAdress!
                }

                if device.lastIccid?.lowercased().contains(searchTerm) ?? false {
                    title = TinkerStrings.InfoSlider.DeviceCell.LastICCID
                    value = device.lastIccid!
                }

                if device.serialNumber?.lowercased().contains(searchTerm) ?? false {
                    title = TinkerStrings.InfoSlider.DeviceCell.Serial
                    value = device.serialNumber!
                }

                if device.imei?.lowercased().contains(searchTerm) ?? false {
                    title = TinkerStrings.InfoSlider.DeviceCell.IMEI
                    value = device.imei!
                }

                if device.id.lowercased().contains(searchTerm) {
                    title = TinkerStrings.InfoSlider.DeviceCell.DeviceId
                    value = device.id
                }

                if device.notes?.lowercased().contains(searchTerm) ?? false {
                    title = TinkerStrings.InfoSlider.Notes
                    value = "...\(searchTerm)..."
                }

                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        self.nameLabel.text = device.getName()
                        self.typeLabel.setDeviceType(device.type)

                        let property = "\(title!): \(value!)"
                        var attributedProperty = NSMutableAttributedString(string: property)
                        attributedProperty.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: (property.lowercased() as NSString).range(of: searchTerm))
                        self.lastHeardLabel.attributedText = attributedProperty

                        ParticleUtils.animateOnlineIndicatorImageView(self.deviceStateImageView, online: device.connected, flashing: device.isFlashing)
                    }
                }
            }
        } else { //if device is shown without filter
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    //using attributed string to clear possible search highlight
                    self.nameLabel.attributedText = NSAttributedString(string: device.getName())
                    self.typeLabel.setDeviceType(device.type)
                    self.lastHeardLabel.attributedText = NSAttributedString(string: device.lastHeard?.tinkerFormattedString() ?? TinkerStrings.DeviceList.Unknown)

                    ParticleUtils.animateOnlineIndicatorImageView(self.deviceStateImageView, online: device.connected, flashing: device.isFlashing)
                }
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()

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
