//
// Created by Raimundas Sakalauskas on 2019-04-24.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
                red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
                green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
                blue: CGFloat(rgb & 0xFF) / 255.0,
                alpha: alpha
        )
    }
}