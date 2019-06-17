//
// Created by Raimundas Sakalauskas on 2019-06-17.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.values = [-15, 15, -7.5, 7.5, 0]
        self.layer.add(animation, forKey: "shake")
    }
}

