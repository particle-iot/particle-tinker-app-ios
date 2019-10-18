//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupNameDeviceViewController: MeshSetupTextInputViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupTextInputView"
    }

    internal var callback: ((String) -> ())!
    private var currentName: String?

    func setup(didEnterName: @escaping (String) -> (), deviceType: ParticleDeviceType?, currentName: String? = nil) {
        self.callback = didEnterName
        self.deviceType = deviceType
        self.currentName = currentName
    }

    override func setContent() {
        titleLabel.text = MeshStrings.DeviceName.Title
        inputTitleLabel.text = MeshStrings.DeviceName.InputTitle
        noteTitleLabel.text = MeshStrings.DeviceName.NoteTitle
        noteTextLabel.text = MeshStrings.DeviceName.NoteText

        inputTextField.text = currentName ?? MeshStrings.getRandomDeviceName()
        continueButton.isEnabled = validateInput()

        continueButton.setTitle(MeshStrings.DeviceName.Button, for: .normal)
    }

    override func setStyle() {
        super.setStyle()

        self.inputTextField.isSecureTextEntry = false
    }

    override func submit() {
        super.submit()

        self.currentName = self.inputTextField.text!
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
