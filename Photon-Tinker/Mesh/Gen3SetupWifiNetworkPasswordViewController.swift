//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupWifiNetworkPasswordViewController: Gen3SetupTextInputViewController, Storyboardable{

    static var nibName: String {
        return "Gen3SetupTextInputView"
    }

    internal var callback: ((String) -> ())!

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func setContent() {
        self.noteView.isHidden = true

        titleLabel.text = Gen3SetupStrings.WifiNetworkPassword.Title
        inputTitleLabel.text = Gen3SetupStrings.WifiNetworkPassword.InputTitle
        continueButton.setTitle(Gen3SetupStrings.WifiNetworkPassword.Button, for: .normal)
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
