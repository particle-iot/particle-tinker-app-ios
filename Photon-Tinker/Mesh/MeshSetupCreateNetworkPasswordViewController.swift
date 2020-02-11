//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupCreateNetworkPasswordViewController: MeshSetupTextInputViewController, Storyboardable{

    @IBOutlet weak var repeatTitleLabel: ParticleLabel!
    @IBOutlet weak var repeatPasswordTextField: ParticleTextField!
    
    internal var callback: ((String) -> ())!

    override func viewDidLoad() {
        super.viewDidLoad()

        repeatPasswordTextField.delegate = self
    }

    func setup(didEnterNetworkPassword: @escaping (String) -> ()) {
        self.callback = didEnterNetworkPassword
    }

    //this screen is too big for iphone6 so we don't open keyboard for it
    override func shouldAutoFocusInput() -> Bool {
        return ScreenUtils.getPhoneScreenSizeClass() >= .iPhone6
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.CreateNetworkPassword.Title
        inputTitleLabel.text = Gen3SetupStrings.CreateNetworkPassword.InputTitle
        repeatTitleLabel.text = Gen3SetupStrings.CreateNetworkPassword.RepeatTitle
        noteTextLabel.text = Gen3SetupStrings.CreateNetworkPassword.NoteText
        noteTitleLabel.text = Gen3SetupStrings.CreateNetworkPassword.NoteTitle


        continueButton.setTitle(Gen3SetupStrings.CreateNetworkPassword.Button, for: .normal)
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.inputTextField) {
            DispatchQueue.main.async {
                self.repeatPasswordTextField.becomeFirstResponder()
                self.repeatPasswordTextField.selectedTextRange = self.repeatPasswordTextField.textRange(from: self.repeatPasswordTextField.beginningOfDocument, to: self.repeatPasswordTextField.endOfDocument)
            }
        } else if validateInput() {
            DispatchQueue.main.async {
                textField.resignFirstResponder()
                self.submit()
            }
        }

        return false
    }


    override func setStyle() {
        super.setStyle()

        self.repeatTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: ParticleStyle.InputTitleColor)
        self.repeatPasswordTextField.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        self.inputTextField.isSecureTextEntry = true
        self.repeatPasswordTextField.isSecureTextEntry = true
    }

    override func submit() {
        if let text = inputTextField.text, text.count >= 1,
           repeatPasswordTextField.text == inputTextField.text {
            super.submit()
            callback!(self.inputTextField.text!)
        } else {
            self.setWrongInput(message: Gen3SetupStrings.CreateNetworkPassword.PasswordsDoNotMatch)
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
