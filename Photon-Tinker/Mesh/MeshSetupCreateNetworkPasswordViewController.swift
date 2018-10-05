//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupCreateNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    @IBOutlet weak var repeatTextLabel: MeshLabel!
    @IBOutlet weak var repeatPasswordTextField: MeshTextField!
    
    internal var callback: ((String) -> ())!

    override func viewDidLoad() {
        super.viewDidLoad()

        repeatPasswordTextField.delegate = self
    }

    func setup(didEnterNetworkPassword: @escaping (String) -> ()) {
        self.callback = didEnterNetworkPassword
    }


    override func setContent() {
        titleLabel.text = MeshSetupStrings.CreateNetworkPassword.Title
        noteTextLabel.text = MeshSetupStrings.CreateNetworkPassword.NoteText
        noteTitleLabel.text = MeshSetupStrings.CreateNetworkPassword.NoteTitle
        repeatTextLabel.text = MeshSetupStrings.CreateNetworkPassword.Repeat

        continueButton.setTitle(MeshSetupStrings.CreateNetworkPassword.Button, for: .normal)
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.inputTextField) {
            self.repeatPasswordTextField.becomeFirstResponder()
        } else if validateInput() {
            textField.resignFirstResponder()
            submit()
        }

        return false
    }


    override func setStyle() {
        super.setStyle()

        self.repeatTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        self.repeatPasswordTextField.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        self.inputTextField.isSecureTextEntry = true
        self.repeatPasswordTextField.isSecureTextEntry = true
    }

    override func submit() {
        if let text = inputTextField.text, text.count >= 1,
           repeatPasswordTextField.text == inputTextField.text {
            super.submit()
            callback!(self.inputTextField.text!)
        } else {
            self.setWrongInput(message: MeshSetupStrings.CreateNetworkPassword.PasswordsDoNotMatch)
        }
    }

    override func validateInput() -> Bool {
        if let text = inputTextField.text, text.count >= 1,
            let repeatText = repeatPasswordTextField.text, repeatText.count >= 1 {
            return true
        } else {
            return false
        }
    }
}
