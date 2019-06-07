//
// Created by Raimundas Sakalauskas on 2019-06-06.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorInfoSliderView: UIView, UIGestureRecognizerDelegate {
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collapsedContent: UIView!
    @IBOutlet weak var collapsedDeviceImageView: UIImageView!
    
    
    @IBOutlet weak var expandedContent: UIView!
    @IBOutlet weak var expandedDeviceImageView: UIImageView!

    let contentSwitchDistanceInPixels: CGFloat = 180
    let contentSwitchDelayInPixels: CGFloat = 100

    var device: ParticleDevice!
    var collapsedPosConstraint: CGFloat!
    var collapsedPosFrame: CGFloat!


    var panGestureRecognizer: UIPanGestureRecognizer!
    var startY: CGFloat = 0
    var collapsed: Bool = true
    var animating: Bool = false
    var beingDragged: Bool = false
    var displayLink: CADisplayLink!

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
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(rgb: 0xD9D8D6).cgColor

        self.adjustConstraintPositions()
        self.yConstraint.constant = collapsedPosConstraint

        self.collapsedDeviceImageView.image = self.device.getImage()
        self.expandedDeviceImageView.image = self.device.getImage()


        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureTriggered))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.isEnabled = true
        self.addGestureRecognizer(panGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.adjustConstraintPositions()

        //if safe area insets change during idle state
        if !animating && !beingDragged {
            if (self.yConstraint.constant > 0) {
                self.yConstraint.constant = collapsedPosConstraint
            }
        }

        let progress = min(self.contentSwitchDistanceInPixels, self.collapsedPosFrame - self.frame.origin.y - self.contentSwitchDelayInPixels) / self.contentSwitchDistanceInPixels
        updateState(progress: progress)
    }

    private func updateState(progress: CGFloat) {
        self.layer.cornerRadius = 10 * progress

        self.collapsedContent.alpha = 1 - progress
        self.expandedContent.alpha = progress
    }


    private func adjustConstraintPositions() {
        collapsedPosConstraint = UIScreen.main.bounds.height - 100
        collapsedPosFrame = collapsedPosConstraint
        if #available(iOS 11, *), let superview = self.superview {
            self.heightConstraint.constant = self.safeAreaInsets.bottom + 11

            collapsedPosConstraint! -= (superview.safeAreaInsets.bottom + superview.safeAreaInsets.top)
            collapsedPosFrame = collapsedPosConstraint + superview.safeAreaInsets.top
        }
    }


    @objc
    func panGestureTriggered(_ recognizer:UIPanGestureRecognizer) {
        switch (recognizer.state) {
            case.began:
                self.beingDragged = true
                let pos = recognizer.translation(in: self)
                self.startY = yConstraint.constant
            case .changed:
                let change = recognizer.translation(in: self)

                var offset = startY + change.y
                if (offset >= collapsedPosConstraint) {
                    //if we reach end of motion, move initial offset so that when user
                    //starts scrolling in different direction he gets instant feedback
                    self.startY = collapsedPosConstraint - change.y
                    offset = collapsedPosConstraint
                } else if (offset <= 0) {
                    //if we reach end of motion, move initial offset so that when user
                    //starts scrolling in different direction he gets instant feedback
                    self.startY = 0 - change.y
                    offset = 0
                }

                yConstraint.constant = offset
                self.layoutSubviews()
            case .failed:
                fallthrough
            case.cancelled:
                fallthrough
            case .ended:
                self.beingDragged = false

                let change = recognizer.translation(in: self)
                let velocity = recognizer.velocity(in: self)

                if (collapsed) {
                    if (-1 * change.y > collapsedPosConstraint / 4) || (-1 * (change.y + velocity.y) > collapsedPosConstraint) {
                        expand()
                    } else {
                        collapse()
                    }
                } else {
                    if (change.y > collapsedPosConstraint / 4) || ((change.y + velocity.y) > collapsedPosConstraint) {
                        collapse()
                    } else {
                        expand()
                    }
                }

            case.possible:
                //do nothing
                break
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !animating
    }


    func expand() {
        animating = true

        self.superview?.layoutIfNeeded()
        let duration:Double = Double(self.yConstraint.constant / self.collapsedPosConstraint * 0.5)
        self.yConstraint.constant = 0

        animateStateChange(duration: duration, collapsed: false)
    }

    func collapse() {
        animating = true

        self.superview?.layoutIfNeeded()
        let duration:Double = Double((self.collapsedPosConstraint - self.yConstraint.constant) / self.collapsedPosConstraint * 0.5)
        self.yConstraint.constant = self.collapsedPosConstraint

        animateStateChange(duration: duration, collapsed: true)
    }

    private func animateStateChange(duration: Double, collapsed: Bool) {
        displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)

        UIView.animate(withDuration: duration, delay:0, options:.curveEaseOut, animations: { () -> Void in
            self.superview?.layoutIfNeeded()
        }, completion: { [weak self] b in
            self?.displayLink.invalidate()
            self?.displayLink = nil
            self?.animating = false
            self?.collapsed = collapsed
        })
    }

    @objc func animationDidUpdate(displayLink: CADisplayLink) {
        let presentationLayer = self.layer.presentation() as! CALayer

        let progress = min(self.contentSwitchDistanceInPixels, self.collapsedPosFrame - presentationLayer.frame.origin.y - self.contentSwitchDelayInPixels) / self.contentSwitchDistanceInPixels
        self.updateState(progress: progress)
    }
}
