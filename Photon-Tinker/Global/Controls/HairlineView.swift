//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class HairlineView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        for constraint in self.constraints {
            if let _ = constraint.firstItem as? HairlineView,
               constraint.firstAttribute == .height,
               constraint.firstAnchor.isKind(of: NSLayoutDimension.self),
               constraint.secondItem == nil,
               constraint.secondAnchor == nil {
                constraint.constant = (1.0 / UIScreen.main.scale)
                return
            }
        }
    }
}
