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

    func setup(didEnterName: @escaping (String) -> (), deviceType: ParticleDeviceType?) {
        self.callback = didEnterName
        self.deviceType = deviceType
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.DeviceName.Title
        textLabel.text = MeshSetupStrings.DeviceName.Text

        continueButton.setTitle(MeshSetupStrings.DeviceName.Button, for: .normal)
    }

    override func setStyle() {
        super.setStyle()

        self.inputTextField.isSecureTextEntry = false
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
