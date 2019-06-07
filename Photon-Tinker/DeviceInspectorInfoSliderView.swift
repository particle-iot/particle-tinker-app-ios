//
// Created by Raimundas Sakalauskas on 2019-06-06.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorInfoSliderView: UIView {
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var device: ParticleDevice!
    var collapsedPosConstraint: CGFloat!
    var collapsedPosFrame: CGFloat!

    var animating: Bool = false
    var beingDragged: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(_ device: ParticleDevice!) {
        self.device = device
        internalInit()
    }

    private func internalInit() {
        adjustConstraintPositions()

        self.yConstraint.constant = collapsedPosConstraint
        self.layer.borderWidth = 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        adjustConstraintPositions()

        //if safe area insets change during idle state
        if !animating && !beingDragged {
            if (self.yConstraint.constant > 0) {
                self.yConstraint.constant = collapsedPosConstraint
            }
        }

        let progress = min(120, self.collapsedPosFrame - self.frame.origin.y) / 120
        self.layer.borderColor = UIColor(rgb: 0xD9D8D6).withAlphaComponent(1 - progress).cgColor
        self.layer.cornerRadius = 10 * progress
    }


    private func adjustConstraintPositions() {
        collapsedPosConstraint = UIScreen.main.bounds.height - 100
        collapsedPosFrame = collapsedPosConstraint
        if #available(iOS 11, *), let superview = self.superview {
            self.heightConstraint.constant = self.safeAreaInsets.bottom + 11

            collapsedPosConstraint! -= superview.safeAreaInsets.bottom
            collapsedPosFrame = collapsedPosConstraint + superview.safeAreaInsets.top
        }
    }

}
