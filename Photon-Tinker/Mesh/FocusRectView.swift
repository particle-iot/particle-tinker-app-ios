//
// Created by Raimundas Sakalauskas on 2019-05-30.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class FocusRectView: UIView {
    var focusRectSize: CGSize?
    var focusRectFrameColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if let ct = UIGraphicsGetCurrentContext(), let focusRectSize = focusRectSize {
            let color = (self.focusRectFrameColor ?? UIColor.black.withAlphaComponent(0.65)).cgColor
            ct.setFillColor(color)
            ct.fill(self.bounds)


            let targetHalfHeight = min(focusRectSize.height, self.bounds.height) / 2
            let targetHalfWidth = min(focusRectSize.width, self.bounds.width) / 2
            let cutoutRect = CGRect(x: self.bounds.midX - targetHalfWidth, y: self.bounds.midY - targetHalfHeight, width: targetHalfWidth * 2, height: targetHalfHeight * 2)
            let path = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 8)

            ct.setBlendMode(.destinationOut)
            path.fill()
        }
    }
}
