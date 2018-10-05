//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    internal var callback: ((String) -> ())!

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ExistingNetworkPassword.Title
        noteTextLabel.text = MeshSetupStrings.ExistingNetworkPassword.NoteText
        continueButton.setTitle(MeshSetupStrings.ExistingNetworkPassword.Button, for: .normal)
    }

    override func setStyle() {
        super.setStyle()

        self.inputTextField.isSecureTextEntry = true
    }

    override func submit() {
        super.submit()
        callback!(self.inputTextField.text!)
    }

    override func validateInput() -> Bool {
        if let text = inputTextField.text, text.count >= 6 {
            return true
        } else {
            return false
        }
    }
}
