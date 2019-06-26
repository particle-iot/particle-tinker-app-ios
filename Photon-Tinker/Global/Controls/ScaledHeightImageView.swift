//
// Created by Raimundas Sakalauskas on 2019-06-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {
        if let image = self.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height

            let viewHeight = self.frame.size.height

            let ratio = viewHeight/imageHeight
            let scaledWidth = imageWidth * ratio

            return CGSize(width: scaledWidth, height: viewHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
}
