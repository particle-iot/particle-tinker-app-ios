//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupWifiNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    static var nibName: String {
        return "MeshSetupTextInputView"
    }

    override var rewindFlowOnBack: Bool {
        return true
    }

    internal var callback: ((String) -> ())!

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func setContent() {
        self.noteView.isHidden = true

        titleLabel.text = MeshSetupStrings.WifiNetworkPassword.Title
        inputTitleLabel.text = MeshSetupStrings.WifiNetworkPassword.InputTitle
        continueButton.setTitle(MeshSetupStrings.WifiNetworkPassword.Button, for: .normal)
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
        if let text = inputTextField.text, text.count >= 8 {
            return true
        } else {
            return false
        }
    }
}
