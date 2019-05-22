//
// Created by Raimundas Sakalauskas on 2019-05-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol PinViewDelegate: class {
    func pinViewTapped(pinView: PinView)
    func pinViewLongTapped(pinView: PinView)
}

class PinView: UIView {
    weak var delegate: PinViewDelegate?

    var pin: DevicePin!

    private var button: UIButton!
    private var label: UILabel!

    private var outerPieValueView: PieProgressView!
    private var outerPieFrameView: PieProgressView!

    private var tapGestureRecognizer: UILongPressGestureRecognizer!
    private var touchStartTime: Date?

    convenience init(pin: DevicePin) {
        self.init(frame: .zero)

        self.pin = pin

        self.setup()
    }

    func setup() {
        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = .zero
        button.setImage(UIImage(named: "imgCircle"), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        addSubview(button)
        NSLayoutConstraint.activate([
             button.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -8),
             button.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8),
             button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
             button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        outerPieValueView = PieProgressView(frame: .zero)
        outerPieValueView.translatesAutoresizingMaskIntoConstraints = false
        outerPieValueView.backgroundColor = UIColor.clear
        outerPieValueView.pieBackgroundColor = UIColor.clear
        outerPieValueView.progress = 1
        outerPieValueView.pieBorderWidth = 0
        outerPieFrameView.pieFillColor = UIColor.white // will change
        outerPieValueView.isHidden = true
        addSubview(outerPieValueView)
        NSLayoutConstraint.activate([
            outerPieValueView.widthAnchor.constraint(equalTo: self.widthAnchor),
            outerPieValueView.heightAnchor.constraint(equalTo: self.heightAnchor),
            outerPieValueView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            outerPieValueView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        outerPieFrameView = PieProgressView(frame: .zero)
        outerPieFrameView.translatesAutoresizingMaskIntoConstraints = false
        outerPieFrameView.backgroundColor = UIColor.clear
        outerPieFrameView.pieBackgroundColor = UIColor.clear
        outerPieFrameView.progress = 1
        if (MeshScreenUtils.getPhoneScreenSizeClass() <= .iPhone5) {
            outerPieFrameView.pieBorderWidth = 1.0
        } else {
            outerPieFrameView.pieBorderWidth = 1.5
        }
        outerPieFrameView.pieBorderColor = UIColor.white // will change
        outerPieFrameView.pieFillColor = UIColor.clear
        outerPieFrameView.isHidden = true
        addSubview(outerPieFrameView)
        NSLayoutConstraint.activate([
            outerPieFrameView.widthAnchor.constraint(equalTo: self.widthAnchor),
            outerPieFrameView.heightAnchor.constraint(equalTo: self.heightAnchor),
            outerPieFrameView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            outerPieFrameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])


        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.center = button.center
        label.text = pin.label
        label.font = UIFont(name: "Gotham-Medium", size: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1, constant: -10),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -8),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinTapped))
        tapGestureRecognizer.minimumPressDuration = 0
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.isEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }


    @objc func pinTapped(sender: UIGestureRecognizer) {
        switch (sender.state) {
            case .began:
                self.touchStartTime = Date()
                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.button.alpha = 0.25
                }
            case .ended:
                if let startTime = self.touchStartTime {
                    if abs(startTime.timeIntervalSinceNow) >= 1.0
                    {
                        self.delegate?.pinViewLongTapped(pinView: self)
                    } else {
                        self.delegate?.pinViewTapped(pinView: self)
                    }
                }
                self.touchStartTime = nil
                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.button.alpha = 1.0
                }
            case .cancelled, .failed:
                self.touchStartTime = nil
                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.button.alpha = 1.0
                }
            case .changed:
                let touchLocation = sender.location(in: self)

                if !self.bounds.contains(touchLocation) {
                    sender.isEnabled = false
                    sender.isEnabled = true
                }
            case .possible:
                //do nothing
                break
        }
    }

    func beginUpdating() {
        self.alpha = 0.35
        self.isUserInteractionEnabled = false
    }

    func endUpdating() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
    }




//
//    func refresh() {
//        self.outerPieValueView.isHidden = true
//        self.outerPieFrameView.isHidden = true
//
//        if (self.active) {
//
//            self.outerPieValueView.pieFillColor = self.pin.selectedFunction.getColor()
//            self.outerPieValueView.pieBorderColor = self.pin.selectedFunction.getColor()
//
//            self.innerPinButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
//            self.label.textColor = .white
//
//            switch (self.pin.selectedFunction) {
//                case .analogRead:
//                    self.outerPieValueView.progress = CGFloat(self.pin.value ?? 0) / PinValueView.Constants.analogReadMaxValue;
//                case .analogWrite:
//                    self.outerPieValueView.progress = CGFloat(self.pin.value ?? 0) / PinValueView.Constants.analogWriteMaxValue;
//                case .analogWriteDAC:
//                    self.outerPieValueView.progress = CGFloat(self.pin.value ?? 0) / PinValueView.Constants.analogWriteDACMaxValue;
//                case .digitalRead, .digitalWrite:
//                    self.outerPieValueView.progress = 1
//                    self.innerPinButton.tintColor = UIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1)
//                    self.label.textColor = .black
//                default:
//                    break
//            }
//
//            //self.valueView?.refresh()
//        }
//    }
//
//    override var isUserInteractionEnabled: Bool {
//        get {
//            return super.isUserInteractionEnabled
//        }
//        set {
//            super.isUserInteractionEnabled = newValue
//            //self.valueView?.isUserInteractionEnabled = newValue
//        }
//    }


}
