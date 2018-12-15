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

    override var allowBack: Bool {
        return false
    }

    func setup(didEnterName: @escaping (String) -> (), deviceType: ParticleDeviceType?, currentName: String? = nil) {
        self.callback = didEnterName
        self.deviceType = deviceType
        self.currentName = currentName
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.DeviceName.Title
        inputTitleLabel.text = MeshSetupStrings.DeviceName.InputTitle
        noteTitleLabel.text = MeshSetupStrings.DeviceName.NoteTitle
        noteTextLabel.text = MeshSetupStrings.DeviceName.NoteText

        inputTextField.text = currentName ?? MeshSetupStrings.getRandomDeviceName()
        continueButton.isEnabled = validateInput()

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
