//
// Created by Raimundas Sakalauskas on 2019-05-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol PinViewDelegate: class {
    func pinDidRequestToSelectFunction(_ pinView: PinView)
//    func pinDidRequestToResetFunction(_ pinView: PinView)
//    func pinDidRequestToReadValue(_ pinView: PinView) //analog read / digital read
//    func pinDidRequestToToggleValue(_ pinView: PinView) //digital write
//    func pinDidRequestToWriteAnalogValue(_ pinView: PinView, value: Int) //analog write
//    func pinDidRequestToHighlightPin(_ pinView: PinView) //analog write
}

class PinView: UIView, UIGestureRecognizerDelegate {
    weak var delegate: PinViewDelegate?

    var pin: DevicePin!

    var selectedFunction: DevicePinFunction?

    private var button: UIButton!
    private var label: UILabel!

    private var outerPieValueView: PieProgressView!
    private var outerPieFrameView: PieProgressView!

    private var longTapGestureRecognizer: UILongPressGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var touchStartTime: Date?

    convenience init(pin: DevicePin) {
        self.init(frame: .zero)

        self.pin = pin

        self.setup()
    }

    func setup() {
        outerPieValueView = PieProgressView(frame: .zero)
        outerPieValueView.translatesAutoresizingMaskIntoConstraints = false
        outerPieValueView.backgroundColor = UIColor.clear
        outerPieValueView.pieBackgroundColor = UIColor.clear
        outerPieValueView.progress = 1
        outerPieValueView.pieBorderWidth = 0
        outerPieValueView.pieFillColor = UIColor.white // will change
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

        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = .zero
        button.setImage(UIImage(named: "imgCircle"), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        button.isUserInteractionEnabled = false
        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -8),
            button.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8),
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
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

        longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLongTapped))
        longTapGestureRecognizer.minimumPressDuration = 1.0
        longTapGestureRecognizer.cancelsTouchesInView = false
        longTapGestureRecognizer.isEnabled = false

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pinTapped))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.isEnabled = true
        tapGestureRecognizer.delegate = self

        self.addGestureRecognizer(longTapGestureRecognizer)
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.tapGestureRecognizer) && (otherGestureRecognizer == self.longTapGestureRecognizer) {
            return true
        }

        return false
    }

    @objc func pinTapped(sender: UIGestureRecognizer) {
        NSLog("sender.state.rawValue = \(sender.state.rawValue)")
        if (sender.state == .ended) {
            self.pinShortTapped()
        }
    }

    private func pinShortTapped() {
        if let selectedFunction = self.selectedFunction {
            if (selectedFunction.contains(.analogRead) || selectedFunction.contains(.digitalRead)) {
//                self.delegate?.pinDidRequestToReadValue(self)
            } else if (selectedFunction.contains(.analogWriteDAC) || selectedFunction.contains(.analogWritePWM)) {
//                self.delegate?.pinDidRequestToHighlightPin(self)
            } else if (selectedFunction.contains(.digitalWrite)) {
//                self.delegate?.pinDidRequestToToggleValue(self)
            }
        } else {
            self.delegate?.pinDidRequestToSelectFunction(self)
        }
    }


    @objc func pinLongTapped(sender: UIGestureRecognizer) {
        if (sender.state == .began) {
            self.selectedFunction = nil
            self.update()
        }
    }

    func update() {
        if let function = self.selectedFunction {
            self.longTapGestureRecognizer.isEnabled = true

            self.outerPieValueView.isHidden = false
            self.outerPieFrameView.isHidden = false

            self.outerPieValueView.pieFillColor = function.getColor()
            self.outerPieFrameView.pieBorderColor = function.getColor()

            switch function {
                case DevicePinFunction.analogWritePWM:
                    self.outerPieValueView.progress = 1
                case DevicePinFunction.analogWriteDAC:
                    self.outerPieValueView.progress = 1
                case DevicePinFunction.analogRead:
                    self.outerPieValueView.progress = 1
                default:
                    self.outerPieValueView.progress = 1
            }

        } else {
            self.longTapGestureRecognizer.isEnabled = false

            self.outerPieValueView.isHidden = true
            self.outerPieFrameView.isHidden = true
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
