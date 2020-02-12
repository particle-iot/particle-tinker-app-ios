//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupNameDeviceViewController: Gen3SetupTextInputViewController, Storyboardable {

    static var nibName: String {
        return "Gen3SetupTextInputView"
    }

    internal var callback: ((String) -> ())!
    private var currentName: String?

    func setup(didEnterName: @escaping (String) -> (), deviceType: ParticleDeviceType?, currentName: String? = nil) {
        self.callback = didEnterName
        self.deviceType = deviceType
        self.currentName = currentName
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.DeviceName.Title
        inputTitleLabel.text = Gen3SetupStrings.DeviceName.InputTitle
        noteTitleLabel.text = Gen3SetupStrings.DeviceName.NoteTitle
        noteTextLabel.text = Gen3SetupStrings.DeviceName.NoteText

        inputTextField.text = currentName ?? Gen3SetupStrings.getRandomDeviceName()
        continueButton.isEnabled = validateInput()

        continueButton.setTitle(Gen3SetupStrings.DeviceName.Button, for: .normal)
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
