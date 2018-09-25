//
//  MeshSetupNameDeviceViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupNameDeviceViewController: MeshSetupTextInputViewController, Storyboardable {

    internal var callback: ((String) -> ())!

    func setup(didEnterPassword: @escaping (String) -> (), deviceType: ParticleDeviceType?) {
        self.callback = didEnterPassword
        self.deviceType = deviceType
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        inputTextField.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.DeviceName.Title
        textLabel.text = MeshSetupStrings.DeviceName.Text

        continueButton.setTitle(MeshSetupStrings.DeviceName.Button, for: .normal)
    }

    override func submit() {
        super.submit()

        callback(self.inputTextField.text!)
    }

    override func validateInput() -> Bool {
        if let text = inputTextField.text, text.count >= 1 {
            return true
        } else {
            return false
        }
    }
}
