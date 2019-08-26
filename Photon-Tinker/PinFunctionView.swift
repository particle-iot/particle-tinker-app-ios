//
// Created by Raimundas Sakalauskas on 2019-05-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

protocol PinFunctionViewDelegate: class {
    func pinFunctionSelected(pin: DevicePin, function: DevicePinFunction?)
}

class PinFunctionView: UIView {

    private let selectedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    private let unselectedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)


    @IBOutlet var pinLabel:ParticleLabel!
    
    @IBOutlet var analogReadButton:ParticleCustomButton!
    @IBOutlet var analogWriteButton:ParticleCustomButton!
    @IBOutlet var digitalReadButton:ParticleCustomButton!
    @IBOutlet var digitalWriteButton:ParticleCustomButton!

    var pin:DevicePin?

    weak var delegate:PinFunctionViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = false
        layer.cornerRadius = 5
        layer.applySketchShadow(color: UIColor(rgb: 0x000000), alpha: 0.3, x: 0, y: 2, blur: 4, spread: 0)

        pinLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        analogReadButton.layer.borderColor = DevicePinFunction.getColor(function: .analogRead).cgColor
        digitalReadButton.layer.borderColor = DevicePinFunction.getColor(function: .digitalRead).cgColor
        digitalWriteButton.layer.borderColor = DevicePinFunction.getColor(function: .digitalWrite).cgColor
        analogWriteButton.layer.borderColor = DevicePinFunction.getColor(function: .analogWriteDAC).cgColor

        setupButton(analogReadButton)
        setupButton(digitalReadButton)
        setupButton(digitalWriteButton)
        setupButton(analogWriteButton)
    }

    private func setupButton(_ button: ParticleCustomButton!) {
        button.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 2
        button.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setPin(_ pin: DevicePin?) {
        self.pin = pin

        guard let pin = self.pin else {
            return
        }

        pinLabel.text = pin.label

        analogReadButton.isHidden = true
        digitalReadButton.isHidden = true
        digitalWriteButton.isHidden = true
        analogWriteButton.isHidden = true

        if pin.functions.contains(.analogRead) {
            analogReadButton.isHidden = false
        }

        if pin.functions.contains(.digitalRead) {
            digitalReadButton.isHidden = false
        }

        if pin.functions.contains(.digitalWrite) {
            digitalWriteButton.isHidden = false
        }

        if (pin.functions.contains(.analogWritePWM) || pin.functions.contains(.analogWriteDAC)) {
            analogWriteButton.isHidden = false

            if pin.functions.contains(.analogWriteDAC) {
                analogWriteButton.layer.borderColor = DevicePinFunction.getColor(function: .analogWriteDAC).cgColor
            } else {
                analogWriteButton.layer.borderColor = DevicePinFunction.getColor(function: .analogWritePWM).cgColor
            }
        }

        pinLabel.sizeToFit()

    }

    @IBAction func functionSelected(_ sender: UIButton) {
        var function:DevicePinFunction? = nil

        if sender == analogReadButton {
            function = .analogRead
        } else if sender == analogWriteButton {
            if self.pin!.functions.contains(.analogWriteDAC) {
                function = .analogWriteDAC
            } else {
                function = .analogWritePWM
            }
        } else if sender == digitalReadButton {
            function = .digitalRead
        } else if sender == digitalWriteButton {
            function = .digitalWrite
        }

        self.delegate?.pinFunctionSelected(pin: self.pin!, function: function)
    }


}
