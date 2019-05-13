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

    var pin: DevicePin
    var valueView: PinValueView

    var active: Bool = false

    private var innerPinButton: UIButton
    private var outerPinButton: UIButton
    private var label: UILabel

    private var outerPieValueView: PieProgressView
    private var outerPieFrameView: PieProgressView

    private var longPressGestureRecognizer: UILongPressGestureRecognizer
    private var longPressDetected: Bool


    init(pin: DevicePin) {
        self.pin = pin

        self.longPressDetected = false
        self.active = false

        let pinSizingOffset:CGFloat = 6;
        self.frame = CGRect(x: 0, y: 0, width: 38+pinSizingOffset, height: 38+pinSizingOffset)


        innerPinButton = UIButton(type: .system)
        innerPinButton.frame = CGRect(x: 4, y: 4, width: 30 + pinSizingOffset, height: 30 + pinSizingOffset)
        innerPinButton.setImage(UIImage(named: "imgCircle"), for: .normal)
        innerPinButton.setTitle("", for: .normal)
        innerPinButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        innerPinButton.addTarget(self, action: #selector(pinTapped), for: .touchUpInside)

        outerPieValueView = PieProgressView(frame: CGRect(x: 0, y: 0, width: 38 + pinSizingOffset, height: 38 + pinSizingOffset))
        outerPieValueView.backgroundColor = UIColor.clear
        outerPieValueView.pieBackgroundColor = UIColor.clear
        outerPieValueView.progress = 1
        outerPieValueView.pieBorderWidth = 0
        outerPieFrameView.pieFillColor = UIColor.white // will change
        outerPieValueView.isHidden = true

        outerPieFrameView = PieProgressView(frame: CGRect(x: 0, y: 0, width: 38 + pinSizingOffset, height: 38 + pinSizingOffset))
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


        label = UILabel(frame: CGRect(x: 4, y: 4, width: 30 + pinSizingOffset, height: 30 + pinSizingOffset))
        label.center = innerPinButton.center
        label.text = pin.label
        if pin.label.count <= 2 {
            label.font = UIFont(name: "Gotham-Medium", size: 14.0 + (pinSizingOffset / 3))
        } else {
            label.font = UIFont(name: "Gotham-Medium", size: 10.5 + (pinSizingOffset / 3))
        }
        label.textColor = UIColor.white
        label.textAlignment = .center

        addSubview(outerPieFrameView)
        addSubview(outerPieValueView)
        addSubview(innerPinButton)
        addSubview(label)

        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLongTapped))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        longPressGestureRecognizer.cancelsTouchesInView = false
        innerPinButton.addGestureRecognizer(longPressGestureRecognizer)
    }


    @objc func pinTapped(sender: UIButton) {
        if (!self.longPressDetected) {
            self.delegate?.pinViewTapped(pinView: self)
        } else {
            self.longPressDetected = false
        }
    }

    @objc func pinLongTapped(sender: UIButton) {
        if (!self.longPressDetected) {
            self.longPressDetected = true
            self.delegate?.pinViewLongTapped(pinView: self)
        }
    }

    func refresh() {
        self.outerPieValueView.isHidden = true
        self.outerPieFrameView.isHidden = true

        if (self.active) {

            self.outerPieValueView.pieFillColor = self.pin.selectedFunction.getColor()
            self.outerPieValueView.pieBorderColor = self.pin.selectedFunction.getColor()

            self.innerPinButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
            self.label.textColor = .white

            switch (self.pin.selectedFunction) {
                case .analogRead:
                    self.outerPieValueView.progress = self.pin.value/PinValueView.Constants.analogReadMaxValue;
                case .analogWrite:
                    self.outerPieValueView.progress = self.pin.value/PinValueView.Constants.analogWriteMaxValue;
                case .analogWriteDAC:
                    self.outerPieValueView.progress = self.pin.value/PinValueView.Constants.analogWriteDACMaxValue;
                case .digitalRead, .digitalWrite:
                    self.outerPieValueView.progress = 1

                    if let value = self.pin.value {
                        self.innerPinButton.tintColor = UIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1)
                        self.label.textColor = .black
                    }
                default:
                    break
            }

            self.valueView.refresh()
        }
    }

    func setActive(_ active: Bool) {
        self.active = active
        self.valueView.active = active
        self.refresh()
    }

    override var isUserInteractionEnabled: Bool {
        get {
            return super.isUserInteractionEnabled
        }
        set {
            super.isUserInteractionEnabled = newValue
            self.valueView.isUserInteractionEnabled = newValue
        }
    }

    func beginUpdating() {
        self.alpha = 0.35
        self.valueView.alpha = 0.35
        self.isUserInteractionEnabled = false
    }

    func endUpdating() {
        self.alpha = 1
        self.valueView.alpha = 1
        self.isUserInteractionEnabled = true
    }
}
