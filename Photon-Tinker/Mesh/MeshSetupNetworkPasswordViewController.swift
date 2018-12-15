//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    static var nibName: String {
        return "MeshSetupTextInputView"
    }

    internal var callback: ((String) -> ())!

    override var rewindFlowOnBack: Bool {
        return true
    }

    override var allowBack: Bool {
        return false
    }

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ExistingNetworkPassword.Title
        inputTitleLabel.text = MeshSetupStrings.ExistingNetworkPassword.InputTitle
        noteTitleLabel.text = MeshSetupStrings.ExistingNetworkPassword.NoteTitle
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
