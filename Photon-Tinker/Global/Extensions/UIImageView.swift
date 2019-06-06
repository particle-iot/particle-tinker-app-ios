//
// Created by Raimundas Sakalauskas on 2019-05-16.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}