//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupCreateNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    internal var callback: ((String) -> ())!

    func setup(didEnterNetworkPassword: @escaping (String) -> ()) {
        self.callback = didEnterNetworkPassword
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.CreateNetworkPassword.Title
        textLabel.text = MeshSetupStrings.CreateNetworkPassword.Text
        continueButton.setTitle(MeshSetupStrings.CreateNetworkPassword.Button, for: .normal)
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
