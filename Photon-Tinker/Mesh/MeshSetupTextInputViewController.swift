//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupTextInputViewController: MeshSetupViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: MeshLabel!

    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteTitleLabel: MeshLabel!
    @IBOutlet weak var noteTextLabel: MeshLabel!

    @IBOutlet weak var inputTitleLabel: MeshLabel!
    @IBOutlet weak var inputTextField: MeshTextField!

    @IBOutlet weak var continueButton: MeshSetupButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextField.delegate = self
        continueButton.isEnabled = validateInput()

        addFadableViews()
    }

    private func addFadableViews() {
        if viewsToFade == nil {
            viewsToFade = [UIView]()
        }

        viewsToFade!.append(titleLabel)
        viewsToFade!.append(inputTitleLabel)
        viewsToFade!.append(inputTextField)
        viewsToFade!.append(noteTextLabel)
        viewsToFade!.append(noteTitleLabel)
        viewsToFade!.append(continueButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (shouldAutoFocusInput()) {
            focusInputText()
        }
    }

    open func shouldAutoFocusInput() -> Bool {
        return MeshScreenUtils.getPhoneScreenSizeClass() > .iPhone5
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if validateInput() {
            submit()
        }

        return false
    }

    override func setStyle() {
        noteTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.PrimaryTextColor)

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
        inputTextField.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        inputTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.InputTitleColor)
    }

    open func submit() {
        self.fade()
    }

    open func validateInput() -> Bool {
        return false
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        self.view.endEditing(true)

        if validateInput() {
            submit()
        }
    }

    func setWrongInput(message: String? = nil) {
        DispatchQueue.main.async {
            self.resume(animated: true)

            if let message = message {
                let alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                    self.focusInputText()
                })
                self.present(alert, animated: true)
            } else {
                self.focusInputText()
            }
        }
    }

    func focusInputText() {
        self.inputTextField.becomeFirstResponder()
        self.inputTextField.selectedTextRange = self.inputTextField.textRange(from: self.inputTextField.beginningOfDocument, to: self.inputTextField.endOfDocument)
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
        self.continueButton.isEnabled = validateInput()
    }
}
