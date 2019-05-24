//
// Created by Raimundas Sakalauskas on 2019-05-12.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol PinViewDelegate: class {
    func pinDidRequestToSelectFunction(_ pinView: PinView)
    func pinDidShowSlider(_ pinView: PinView)
}

class PinView: UIView, UIGestureRecognizerDelegate {
    weak var delegate: PinViewDelegate?
    weak var device:ParticleDevice!

    var pin: DevicePin!

    var selectedFunction: DevicePinFunction?

    private var slider: ASValueTrackingSlider!
    private var button: UIButton!
    private var label: UILabel!
    private var valueLabel: UILabel!

    private var outerPieValueView: PieProgressView!
    private var outerPieFrameView: PieProgressView!

    private var longTapGestureRecognizer: UILongPressGestureRecognizer!
    private var tapGestureRecognizer: UILongPressGestureRecognizer!
    private var touchStartTime: Date?

    private var prefaded: Bool = false
    private var updating: Bool = false
    private var down: Bool = false
    private var sliderVisible: Bool = false

    private var pinValue: Int? = nil

    convenience init(pin: DevicePin, device: ParticleDevice) {
        self.init(frame: .zero)

        self.device = device
        self.pin = pin

        self.setup()
    }

    func setup() {

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
            outerPieFrameView.widthAnchor.constraint(equalTo: self.heightAnchor),
            outerPieFrameView.heightAnchor.constraint(equalTo: self.heightAnchor),
            outerPieFrameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

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
            outerPieValueView.widthAnchor.constraint(equalTo: self.heightAnchor),
            outerPieValueView.heightAnchor.constraint(equalTo: self.heightAnchor),
            outerPieValueView.centerXAnchor.constraint(equalTo: outerPieFrameView.centerXAnchor),
        outerPieValueView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = .zero
        button.setImage(UIImage(named: "imgCircle"), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -8),
            button.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8),
            button.centerXAnchor.constraint(equalTo: outerPieFrameView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = pin.label
        label.font = UIFont(name: "Gotham-Medium", size: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -10),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -8),
            label.centerXAnchor.constraint(equalTo: outerPieFrameView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        valueLabel = UILabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont(name: "Gotham-Medium", size: 15.0)
        valueLabel.textColor = UIColor.white
        valueLabel.text = ""
        valueLabel.isHidden = true
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])


        slider = ASValueTrackingSlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(self.sliderMoved), for: .valueChanged)
        slider.addTarget(self, action: #selector(self.sliderSetValue), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.sliderSetValue), for: .touchUpOutside)

        slider.backgroundColor = UIColor.clear
        slider.minimumValue = 0
        slider.isContinuous = true
        slider.value = 0
        slider.isHidden = true
        slider.isUserInteractionEnabled = false

        slider.popUpViewCornerRadius = 3.0
        slider.setMaxFractionDigitsDisplayed(0)
        slider.font = UIFont(name: "Gotham-Medium", size: 20)
        slider.textColor = UIColor.darkGray

        addSubview(slider)

        if (pin.side == .left) {
            valueLabel.textAlignment = .left
            NSLayoutConstraint.activate([
                valueLabel.leftAnchor.constraint(equalTo: outerPieFrameView.rightAnchor, constant: 8),
                valueLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
                outerPieFrameView.leftAnchor.constraint(equalTo: self.leftAnchor),
            ])
        } else {
            valueLabel.textAlignment = .right

            NSLayoutConstraint.activate([
                valueLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
                valueLabel.rightAnchor.constraint(equalTo: outerPieFrameView.leftAnchor, constant: -8),
                outerPieFrameView.rightAnchor.constraint(equalTo: self.rightAnchor),
            ])
        }

        longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLongTapped))
        longTapGestureRecognizer.minimumPressDuration = 1.0
        longTapGestureRecognizer.cancelsTouchesInView = false
        longTapGestureRecognizer.isEnabled = false

        tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinTapped))
        tapGestureRecognizer.minimumPressDuration = 0.0
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.isEnabled = true
        tapGestureRecognizer.delegate = self

        self.button.addGestureRecognizer(longTapGestureRecognizer)
        self.button.addGestureRecognizer(tapGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.slider.frame = self.valueLabel.frame
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.tapGestureRecognizer) && (otherGestureRecognizer == self.longTapGestureRecognizer) {
            return true
        }

        return false
    }

    @objc func pinTapped(sender: UIGestureRecognizer) {
        if (sender.state == .ended) {
            self.down = false
            self.adjustAlpha()

            if let selectedFunction = self.selectedFunction {
                self.delegate?.pinDidShowSlider(self) //force slider hiding for everyone

                if (selectedFunction.contains(.analogRead) || selectedFunction.contains(.digitalRead)) {
                    self.beginUpdating()
                } else if (selectedFunction.contains(.analogWriteDAC) || selectedFunction.contains(.analogWritePWM)) {
                    self.showSlider()
                } else if (selectedFunction.contains(.digitalWrite)) {
                    self.toggleValue()
                }
            } else {
                self.delegate?.pinDidRequestToSelectFunction(self)
            }
        } else if (sender.state == .began) {
            self.down = true
            self.adjustAlpha()
        }
    }



    @objc func pinLongTapped(sender: UIGestureRecognizer) {
        if (sender.state == .began) {
            self.selectedFunction = nil
            self.down = false
            self.sliderVisible = false
            self.adjustAlpha()
            self.update()

            self.delegate?.pinDidShowSlider(self) //force slider hiding for everyone
        }
    }


    private func showSlider() {
        self.slider.value = Float(self.pinValue!)
        self.sliderVisible = true
        self.update()

        self.delegate?.pinDidShowSlider(self)
    }

    func hideSlider() {
        self.sliderVisible = false
        self.update()
    }


    func update() {
        self.isUserInteractionEnabled = true

        if (self.updating) {
            self.isUserInteractionEnabled = false
        }

        if let function = self.selectedFunction {
            if (self.prefaded) {
                self.isUserInteractionEnabled = false
            }
            self.longTapGestureRecognizer.isEnabled = true

            self.outerPieValueView.isHidden = false
            self.outerPieFrameView.isHidden = false

            self.outerPieValueView.pieFillColor = function.getColor()
            self.outerPieFrameView.pieBorderColor = function.getColor()

            self.valueLabel.isHidden = (self.pinValue == nil)

            if (self.sliderVisible) {
                self.valueLabel.isHidden = true

                self.slider.isUserInteractionEnabled = true
                self.slider.isHidden = false
            } else {
                self.slider.isUserInteractionEnabled = false
                self.slider.isHidden = true
            }

            switch function {
                case DevicePinFunction.analogWritePWM:
                    let value = self.pinValue ?? 0
                    self.outerPieValueView.progress = CGFloat(value) / DevicePinFunction.Constants.analogWritePWMMaxValue
                    self.valueLabel.text = "\(value)"
                case DevicePinFunction.analogWriteDAC:
                    let value = self.pinValue ?? 0
                    self.outerPieValueView.progress = CGFloat(value) / DevicePinFunction.Constants.analogWriteDACMaxValue
                    self.valueLabel.text = "\(value)"
                case DevicePinFunction.analogRead:
                    let value = self.pinValue ?? 0
                    self.outerPieValueView.progress = CGFloat(value) / DevicePinFunction.Constants.analogReadMaxValue
                    self.valueLabel.text = "\(value)"
                case DevicePinFunction.digitalRead:
                    self.outerPieValueView.progress = 1
                    self.valueLabel.text = self.pinValue ?? 0 > 0 ? "HIGH" : "LOW"
                case DevicePinFunction.digitalWrite:
                    self.outerPieValueView.progress = 1
                    self.valueLabel.text = self.pinValue ?? 0 > 0 ? "HIGH" : "LOW"
                default:
                    break
            }

        } else {
            self.longTapGestureRecognizer.isEnabled = false

            self.outerPieValueView.isHidden = true
            self.outerPieFrameView.isHidden = true

            self.slider.isUserInteractionEnabled = false
            self.slider.isHidden = true

            self.valueLabel.isHidden = true
        }
    }

    //used when showing function view
    func fadePin() {
        self.prefaded = true

        self.adjustAlpha()
        self.update()
    }

    func unfadePin() {
        self.prefaded = false

        self.adjustAlpha()
        self.update()
    }


    private func toggleValue() {
        if (self.pinValue! == 0) {
            self.pinValue = 1
        } else {
            self.pinValue = 0
        }

        self.beginUpdating()
    }

    func beginUpdating() {
        self.updating = true

        guard let selectedFunction = self.selectedFunction else {
            fatalError("function not selected!?!?")
        }

        if (self.selectedFunction == DevicePinFunction.analogRead || self.selectedFunction == DevicePinFunction.digitalRead) {
            self.readValue()
        } else {
            self.postValue()
        }

        self.update()
        self.adjustAlpha()
    }

    func setFunction(_ function: DevicePinFunction) {
        self.selectedFunction = function

        if (self.selectedFunction!.isWrite()) {
            self.pinValue = 0
            if (self.selectedFunction != DevicePinFunction.digitalWrite) {
                self.showSlider()
            }
            self.beginUpdating()
        } else {
            self.pinValue = nil
            self.beginUpdating()
        }

        slider.popUpViewColor = self.selectedFunction!.getColor()
        switch self.selectedFunction! {
            case .analogWriteDAC:
                slider.maximumValue = Float(DevicePinFunction.Constants.analogWriteDACMaxValue)
            case .analogWritePWM:
                slider.maximumValue = Float(DevicePinFunction.Constants.analogWritePWMMaxValue)
            default:
                slider.maximumValue = 100
        }

        self.update()
    }

    func endUpdating() {
        self.updating = false

        self.update()
        self.adjustAlpha()
    }

    func adjustAlpha() {
        var targetAlpha:CGFloat = 1.0

        if (self.down) {
            targetAlpha = min(0.5, targetAlpha)
        }

        if (self.prefaded) {
            targetAlpha = min(0.35, targetAlpha)
        }

        if (self.updating) {
            targetAlpha = min(0.15, targetAlpha)
        }

        UIView.animate(withDuration: 0.125) { [weak self] () -> Void in
            if let self = self {
                self.alpha = targetAlpha
            }
        }
    }

    func readValue() {
        self.device.callFunction(self.selectedFunction!.getLogicalName()!, withArguments: [self.pin.logicalName]) { [weak self] result, error in
            if let self = self {
                if (error == nil) {
                    self.pinValue = Int(result!)
                    self.endUpdating()
                } else {
                    //todo: show error

                    self.pinValue = nil
                    self.endUpdating()
                }
            }
        }
    }


    func postValue() {
        var args: [Any] = [self.pin.logicalName]
        if (self.selectedFunction == DevicePinFunction.digitalWrite) {
            args.append(self.pinValue! > 0 ? "HIGH" : "LOW")
        } else {
            args.append(NSNumber(value: self.pinValue!))
        }

        self.device.callFunction(self.selectedFunction!.getLogicalName()!, withArguments: args) { [weak self] result, error in
            if let self = self {
                if (error == nil && Int(result!) > 0) {
                    self.endUpdating()
                } else {
                    //todo: show error
                    self.endUpdating()
                }
            }
        }
    }

    @objc func sliderMoved(_ slider: ASValueTrackingSlider) {
        self.pinValue = Int(slider.value)
        self.update()
    }

    @objc func sliderSetValue(_ slider: ASValueTrackingSlider) {
        self.pinValue = Int(slider.value)
        self.beginUpdating()
    }


}
