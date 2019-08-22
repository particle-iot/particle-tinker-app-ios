//
// Created by Raimundas Sakalauskas on 2019-05-20.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class TinkerView: UIView, PinViewDelegate, PinFunctionViewDelegate {

    @IBOutlet weak var functionView: PinFunctionView!

    @IBOutlet weak var functionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewCenterYConstraint: NSLayoutConstraint!

    var device: ParticleDevice!
    var pinViews: [String: PinView]! = [:]
    var pinDefinitions:[DevicePin]! = []

    var backgroundImageView: UIImageView!


    deinit {
        self.pinViews.removeAll()
        self.pinDefinitions.removeAll()
    }

    func setup(_ device: ParticleDevice) {
        self.device = device

        self.setupPinsDefinitions()
        self.setupDeviceImage()
        self.setupPins()
        self.setupFunctionView()
    }


    private func setupFunctionView() {
        self.hideFunctionView(instant: true)
        self.functionView.delegate = self
    }

    private func setupPinsDefinitions() {
        if let path = Bundle.main.path(forResource: "tinker_pin_data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                var definitions = try JSONDecoder().decode([DevicePinsDefinition].self, from: data)

                for definition in definitions {
                    if (definition.platformId == Int(self.device.platformId)) {
                        self.pinDefinitions = definition.pins
                        break
                    }
                }
            } catch {
                NSLog("Error: \(error)")
            }
        }
        NSLog("pins: \(pinDefinitions)")
    }

    func setupDeviceImage() {
        // add chip shadow
        let outlineImage: UIImage!
        if (device.is3rdGen()) {
            outlineImage = UIImage(named: "Img3rdGenDevice")!.withRenderingMode(.alwaysTemplate)
        } else {
            outlineImage = UIImage(named: "imgDeviceShadow")!.withRenderingMode(.alwaysTemplate)
        }

        backgroundImageView = UIImageView(image: outlineImage)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.tintColor = UIColor(rgb: 0xD9D8D6)
        backgroundImageView.contentMode = .scaleToFill

        self.addSubview(backgroundImageView)

        let widthConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: -16)
        widthConstraint.priority = .defaultHigh

        let heightConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: self, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: -64)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor, multiplier: outlineImage.size.height / outlineImage.size.width),
            backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -4),
            backgroundImageView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, constant: -64),
            backgroundImageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, constant: -16),
            widthConstraint,
            heightConstraint
        ])
    }


    private func setupPins() {
        pinViews = [:]

        //create stacks
        var leftStack = UIStackView()
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.alignment = .leading
        leftStack.distribution = .equalSpacing
        leftStack.spacing = 8
        self.addSubview(leftStack)

        var rightStack = UIStackView()
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.distribution = .equalSpacing
        rightStack.spacing = 8
        self.addSubview(rightStack)

        //set stack constraints
        NSLayoutConstraint.activate([
            leftStack.leftAnchor.constraint(equalTo: self.backgroundImageView.leftAnchor, constant: 8),
            leftStack.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor, constant: 8),
            leftStack.heightAnchor.constraint(equalTo: self.backgroundImageView.heightAnchor, multiplier: (device.is3rdGen() ? 1 : 0.94), constant: -16),
            leftStack.widthAnchor.constraint(equalTo: self.backgroundImageView.widthAnchor, multiplier: 0.5, constant: -8),

            rightStack.rightAnchor.constraint(equalTo: self.backgroundImageView.rightAnchor, constant: -8),
            rightStack.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor, constant: 8),
            rightStack.heightAnchor.constraint(equalTo: self.backgroundImageView.heightAnchor, multiplier: (device.is3rdGen() ? 1 : 0.94), constant: -16),
            rightStack.widthAnchor.constraint(equalTo: self.backgroundImageView.widthAnchor, multiplier: 0.5, constant: -8)
        ])

        //this is the first pin
        //first pin will be used to determine size
        //remaining pins will have width & height == root.width & root.height
        var rootPin: PinView? = nil

        for pin in self.pinDefinitions {
            let pinView = PinView(pin: pin, device: self.device)
            pinView.delegate = self
            pinView.translatesAutoresizingMaskIntoConstraints = false

            pinViews[pin.label] = pinView

            if pin.side == .left {
                leftStack.addArrangedSubview(pinView)
            } else {
                rightStack.addArrangedSubview(pinView)
            }

            if (rootPin == nil){
                rootPin = pinView

                let widthConstraint = pinView.widthAnchor.constraint(equalToConstant: 42)
                widthConstraint.priority = .defaultHigh

                let heightConstraint = pinView.heightAnchor.constraint(equalToConstant: 42)
                heightConstraint.priority = .defaultHigh

                NSLayoutConstraint.activate([
                    pinView.heightAnchor.constraint(lessThanOrEqualToConstant: 42),
                    pinView.widthAnchor.constraint(equalTo: leftStack.widthAnchor),
                    heightConstraint
                ])
            } else {
                NSLayoutConstraint.activate([
                    pinView.widthAnchor.constraint(equalTo: rootPin!.widthAnchor),
                    pinView.heightAnchor.constraint(equalTo: rootPin!.heightAnchor)
                ])
            }
        }

        //balans stacks to have equal amount of views
        if (leftStack.arrangedSubviews.count < rightStack.arrangedSubviews.count) {
            for i in leftStack.arrangedSubviews.count ..< rightStack.arrangedSubviews.count {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .clear
                leftStack.insertArrangedSubview(view, at: 0)
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalTo: rootPin!.widthAnchor),
                    view.heightAnchor.constraint(equalTo: rootPin!.heightAnchor)
                ])
            }
        }

        if (rightStack.arrangedSubviews.count < leftStack.arrangedSubviews.count) {
            for i in rightStack.arrangedSubviews.count ..< leftStack.arrangedSubviews.count {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .clear
                rightStack.insertArrangedSubview(view, at: 0)
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalTo: rootPin!.widthAnchor),
                    view.heightAnchor.constraint(equalTo: rootPin!.heightAnchor)
                ])
            }
        }
    }

    func pinDidRequestToSelectFunction(_ pinView: PinView) {
        //hide if no function selected and function view not visible for current pin
        if (pinView.selectedFunction == nil && pinView.pin != functionView.pin) {
            self.functionView.setPin(pinView.pin)
            self.showFunctionView(origin: pinView)
        } else {
            self.functionView.setPin(nil)
            self.hideFunctionView(instant: false)
        }
    }

    func pinDidShowSlider(_ pinView: PinView) {
        for pin in pinViews.values {
            if pin != pinView {
                pin.hideSlider()
            }
        }
    }

    private func showFunctionView(origin: PinView) {
        if (!self.functionView.isHidden) {
            self.hideFunctionView(instant: true)
        }

        for pin in pinViews.values {
            pin.hideSlider()
        }

        DispatchQueue.main.async {
            self.bringSubview(toFront: self.functionView)
            self.functionView.isHidden = false

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.functionView.alpha = 1
            }, completion: { finished in

            })

            for pinView in self.pinViews.values {
                if pinView != origin {
                    pinView.fadePin()
                }
            }
        }
    }

    private func hideFunctionView(instant: Bool) {
        for pin in pinViews.values {
            pin.hideSlider()
        }

        if (instant) {
            self.functionView.alpha = 0
            self.functionView.isHidden = true

            for pinView in self.pinViews.values {
                pinView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.functionView.alpha = 0

            }, completion: { finished in
                self.functionView.isHidden = true
            })

            for pinView in self.pinViews.values {
                pinView.unfadePin()
            }
        }
    }

    func pinFunctionSelected(pin: DevicePin, function: DevicePinFunction?) {
        self.functionView.setPin(nil)
        self.hideFunctionView(instant: false)

        if let function = function {
            self.pinViews[pin.label]!.setFunction(function)
        }
    }

}



