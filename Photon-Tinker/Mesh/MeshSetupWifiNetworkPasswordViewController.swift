//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupWifiNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    static var nibName: String {
        return "MeshSetupTextInputView"
    }

    internal var callback: ((String) -> ())!

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func setContent() {
        self.noteView.isHidden = true

        titleLabel.text = MeshStrings.WifiNetworkPassword.Title
        inputTitleLabel.text = MeshStrings.WifiNetworkPassword.InputTitle
        continueButton.setTitle(MeshStrings.WifiNetworkPassword.Button, for: .normal)
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
        if let text = inputTextField.text, text.count >= 5 {
            return true
        } else {
            return false
        }
    }
}
