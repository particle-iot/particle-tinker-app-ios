//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupCreateNetworkNameViewController: MeshSetupTextInputViewController, Storyboardable{

    static var nibName: String {
        return "MeshSetupTextInputView"
    }

    internal var callback: ((String) -> ())!

    func setup(didEnterNetworkName: @escaping (String) -> ()) {
        self.callback = didEnterNetworkName
    }

    override func setContent() {

        titleLabel.text = MeshStrings.CreateNetworkName.Title
        inputTitleLabel.text = MeshStrings.CreateNetworkName.InputTitle
        noteTitleLabel.text = MeshStrings.CreateNetworkName.NoteTitle
        noteTextLabel.text = MeshStrings.CreateNetworkName.NoteText
        continueButton.setTitle(MeshStrings.CreateNetworkName.Button, for: .normal)
    }

    override func setStyle() {
        super.setStyle()

        self.inputTextField.isSecureTextEntry = false
    }

    override func submit() {
        super.submit()
        callback!(self.inputTextField.text!)
    }

    override func validateInput() -> Bool {
        if let text = inputTextField.text, text.count > 0, text.count <= 16 {
            return true
        } else {
            return false
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z0-9_\\-]+")
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        return matches.count == 0
    }
}
