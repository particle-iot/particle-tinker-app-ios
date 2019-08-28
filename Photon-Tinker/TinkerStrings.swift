//
// Created by Raimundas Sakalauskas on 2019-05-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UIView {
    open override func awakeFromNib() {
        super.awakeFromNib()

        self.replaceTinkerStrings()
    }

    open func replaceTinkerStrings() {
        let subviews = self.subviews

        for subview in subviews {
            if subview is UILabel {
                let label = subview as! UILabel
                label.text = label.text?.tinkerLocalized()
            } else if (subview is ParticleButton) {
                let button = subview as! ParticleButton
                button.setTitle(button.currentTitle?.tinkerLocalized(), for: .normal)
            } else if (subview is UIView) {
                subview.replaceTinkerStrings()
            }
        }
    }
}

extension String {
    func tinkerLocalized() -> String {
        return NSLocalizedString(self, tableName: "TinkerStrings", comment: "")
    }
}

class TinkerStrings {
    enum Welcome {
        static let GetStartedButton = "Tinker.Welcome.GetStartedButton".tinkerLocalized()
        static let Version = "Tinker.Welcome.Version".tinkerLocalized()
    }

    enum DeviceList {
        static let Title = "Tinker.DeviceList.Title".tinkerLocalized()
    }
}

