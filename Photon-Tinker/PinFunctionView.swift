//
// Created by Raimundas Sakalauskas on 2019-05-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

protocol PinFunctionViewDelegate: class {
    func pinFunctionSelected(function: DevicePinFunction)
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
    var pinView:PinView?

    weak var delegate:PinFunctionViewDelegate?

    func setPin(_ pin: DevicePin) {
        self.pin = pin

        pinLabel.text = pin.label

        analogReadImageView.isHidden = true
        analogReadButton.backgroundColor = unselectedColor

        analogWriteImageView.isHidden = true
        analogWriteButton.backgroundColor = unselectedColor

        digitalReadImageView.isHidden = false
        digitalReadButton.backgroundColor = unselectedColor

        digitalWriteImageView.isHidden = false
        digitalWriteButton.backgroundColor = unselectedColor

        if pin.availableFunctions.contains(.analogRead) {
            analogReadButton.isHidden = false
            analogReadImageView.isHidden = false
        } else {
            analogReadButton.isHidden = true
            analogReadImageView.isHidden = true
        }

        if (pin.availableFunctions.contains(.analogWrite) || pin.availableFunctions.contains(.analogWriteDAC)) {
            analogWriteButton.isHidden = false
            analogWriteImageView.isHidden = false

            if pin.availableFunctions.contains(.analogWriteDAC) {
                analogWriteImageView.image = analogWriteImageView.image?.withRenderingMode(.alwaysTemplate)
                analogWriteImageView.tintColor = DevicePinFunction.getColor(function: .analogWriteDAC)
            } else {
                analogWriteImageView.image = analogWriteImageView.image?.withRenderingMode(.alwaysOriginal)
            }
        } else {
            analogWriteButton.isHidden = true
            analogWriteImageView.isHidden = true
        }

        switch pin.selectedFunction {
            case .analogRead:
                analogReadButton.backgroundColor = selectedColor
                analogReadImageView.isHidden = false
            case .analogWriteDAC, .analogWrite:
                analogWriteButton.backgroundColor = selectedColor
                analogWriteImageView.isHidden = false
            case .digitalRead:
                digitalReadButton.backgroundColor = selectedColor
                digitalReadImageView.isHidden = false
            case .digitalWrite:
                digitalWriteButton.backgroundColor = selectedColor
                digitalWriteImageView.isHidden = false
            default:
                break
        }

        pinLabel.sizeToFit()
    }

    @IBAction func functionSelected(_ sender: UIButton) {
        var function = DevicePinFunction.none

        if sender == analogReadButton {
            function = .analogRead
        } else if sender == analogWriteButton {
            if self.pin!.availableFunctions.contains(.analogWriteDAC) {
                function = .analogWriteDAC
            } else {
                function = .analogWrite
            }
        } else if sender == digitalReadButton {
            function = .digitalRead
        } else if sender == digitalWriteButton {
            function = .digitalWrite
        }

        delegate?.pinFunctionSelected(function: function)
    }


}