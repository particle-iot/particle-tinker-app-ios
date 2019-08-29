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

        for subview in subviews {
            if subview is UILabel {
                let label = subview as! UILabel
                label.text = label.text?.tinkerLocalized()
            } else if (subview is UIButton) {
                let button = subview as! UIButton
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

