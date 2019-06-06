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


    @IBOutlet var pinLabel:UILabel!
    
    @IBOutlet var analogReadImageView:UIImageView!
    @IBOutlet var analogReadButton:UIButton!
    
    @IBOutlet var analogWriteImageView:UIImageView!
    @IBOutlet var analogWriteButton:UIButton!
    
    @IBOutlet var digitalReadImageView:UIImageView!
    @IBOutlet var digitalReadButton:UIButton!
    
    @IBOutlet var digitalWriteImageView:UIImageView!
    @IBOutlet var digitalWriteButton:UIButton!

    var pin:DevicePin?

    weak var delegate:PinFunctionViewDelegate?

    func setPin(_ pin: DevicePin?) {
        self.pin = pin

        guard let pin = self.pin else {
            return
        }

        pinLabel.text = pin.label

        analogReadButton.isHidden = true
        analogReadButton.backgroundColor = unselectedColor
        analogReadImageView.isHidden = true

        digitalReadButton.isHidden = true
        digitalReadButton.backgroundColor = unselectedColor
        digitalReadImageView.isHidden = true

        digitalWriteButton.isHidden = true
        digitalWriteButton.backgroundColor = unselectedColor
        digitalWriteImageView.isHidden = true

        analogWriteButton.isHidden = true
        analogWriteButton.backgroundColor = unselectedColor
        analogWriteImageView.isHidden = true

        if pin.functions.contains(.analogRead) {
            analogReadButton.isHidden = false
            analogReadImageView.isHidden = false
        }

        if pin.functions.contains(.digitalRead) {
            digitalReadButton.isHidden = false
            digitalReadImageView.isHidden = false
        }

        if pin.functions.contains(.digitalWrite) {
            digitalWriteButton.isHidden = false
            digitalWriteImageView.isHidden = false
        }

        if (pin.functions.contains(.analogWritePWM) || pin.functions.contains(.analogWriteDAC)) {
            analogWriteButton.isHidden = false
            analogWriteImageView.isHidden = false

            analogWriteImageView.image = analogWriteImageView.image?.withRenderingMode(.alwaysTemplate)

            if pin.functions.contains(.analogWriteDAC) {
                analogWriteImageView.tintColor = DevicePinFunction.getColor(function: .analogWriteDAC)
            } else {
                analogWriteImageView.tintColor = DevicePinFunction.getColor(function: .analogWritePWM)
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
