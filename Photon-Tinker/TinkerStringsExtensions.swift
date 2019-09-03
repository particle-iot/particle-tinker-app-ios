//
// Created by Raimundas Sakalauskas on 2019-08-29.
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

        if self is UILabel {
            let label = self as! UILabel
            label.text = label.text?.tinkerLocalized()
        } else if self is ParticleCustomButton {
            let button = self as! ParticleCustomButton
            NSLog("ParticleCustomButton.currentTitle?.tinkerLocalized() = \(button.currentTitle?.tinkerLocalized())")
            NSLog("button.upperCase = \(button.upperCase)")
            button.setTitle(button.currentTitle?.tinkerLocalized(), for: .normal, upperCase: button.upperCase)
        } else if self is UIButton {
            let button = self as! UIButton
            NSLog("UIButton.currentTitle?.tinkerLocalized() = \(button.currentTitle?.tinkerLocalized())")
            button.setTitle(button.currentTitle?.tinkerLocalized(), for: .normal)
        }
    }
}

extension String {
    func tinkerLocalized() -> String {
        return NSLocalizedString(self, tableName: "TinkerStrings", comment: "")
    }
}

