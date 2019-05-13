//
// Created by Raimundas Sakalauskas on 2019-05-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation



protocol PinValueViewDelegate: class {
    func pinValueViewSliderMoved(_ sender: PinValueView, newValue: Float, touchUp: Bool)
}

class PinValueView: UIView {
    struct Constants {
        static var analogReadMaxValue: Float = 4095.0
        static var analogWriteMaxValue: Float = 255.0
        static var analogWriteDACMaxValue: Float = 4095.0
    }

    weak var delegate: PinValueViewDelegate?

    var pin: DevicePin
    var active: Bool {
        didSet {
            self.isHidden = !active;
        }
    }

    private var valueLabel: UILabel
    private var slider: ASValueTrackingSlider?

    init(pin: DevicePin) {
        super.init(frame: .zero)

        self.pin = pin
        self.active = true
        self.isHidden = false

        var width: CGFloat = 140
        var height: CGFloat = 44

        switch MeshScreenUtils.getPhoneScreenSizeClass() {
            case .iPhone4:
                height = 38
            case .iPhone5:
                height = 140
            case .iPhone6:
                height = 180
            default:
                height = 210
        }

        self.frame = CGRect(x: 0, y: 0, width: width, height: height)

        valueLabel = UILabel(frame: frame)

        if pin.side == .left {
            valueLabel.textAlignment = .left
        } else {
            valueLabel.textAlignment = .right
        }

        valueLabel.font = UIFont(name: "Gotham-Medium", size: 15.0)
        valueLabel.textColor = UIColor.white
        valueLabel.text = ""
        valueLabel.isHidden = true

        addSubview(valueLabel)
    }

    func refresh() {
        valueLabel.hidden = (pin.value == nil)

        if slider {
            valueLabel.isHidden = true
        }

        if (!valueLabel.isHidden) {
            switch pin.selectedFunction {
                case .digitalRead, .digitalWrite:
                    valueLabel.text = pin.value ? "HIGH" : "LOW"
                case .analogRead, .analogWrite:
                    valueLabel.text = String(format: "%ld", UInt(pin.value!))
                default:
                    valueLabel.text = ""
            }
        }
    }

    @objc func sliderMoved(_ slider: ASValueTrackingSlider) {
        delegate?.pinValueViewSliderMoved(self, newValue: slider.value, touchUp: false)
    }

    @objc func sliderSetValue(_ slider: ASValueTrackingSlider) {
        delegate?.pinValueViewSliderMoved(self, newValue: slider.value, touchUp: true)
    }

    func showSlider() {
        if slider == nil {
            valueLabel.isHidden = true
            self.isHidden = false

            slider = ASValueTrackingSlider(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            slider!.addTarget(self, action: #selector(self.sliderMoved), for: .valueChanged)
            slider!.addTarget(self, action: #selector(self.sliderSetValue), for: .touchUpInside)
            slider!.addTarget(self, action: #selector(self.sliderSetValue), for: .touchUpOutside)

            slider!.backgroundColor = UIColor.clear
            slider!.minimumValue = 0.0 as NSNumber

            switch pin.selectedFunction {
                case .analogWriteDAC:
                    slider!.maximumValue = PinValueView.Constants.analogWriteDACMaxValue
                default:
                    slider!.maximumValue = PinValueView.Constants.analogWriteMaxValue
            }

            slider!.continuous = true
            slider!.value = Float(pin.value ?? 0)
            slider!.isHidden = false
            slider!.isUserInteractionEnabled = true

            slider!.popUpViewCornerRadius = 3.0
            slider!.setMaxFractionDigitsDisplayed(0)
            slider!.popUpViewColor = pin.selectedFunctionColor //[UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
            slider!.font = UIFont(name: "Gotham-Medium", size: 20)
            slider!.textColor = UIColor.darkGray //[UIColor colorWithHue:0.55 saturation:1.0 brightness:0.4 alpha:1];

            insertSubview(slider!, aboveSubview: valueLabel)
        }

        setNeedsDisplay()
    }

    func hideSlider() {
        if let slider = slider {
            slider.removeFromSuperview()
            self.slider = nil
        }

        valueLabel.isHidden = false
        self.isHidden = false
    }
}
