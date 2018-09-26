//
//  MeshSetupTextInputViewController.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 25/09/2018.
//  Copyright © 2018 spark. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupTextInputViewController: MeshSetupViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!

    @IBOutlet weak var inputTextField: MeshTextField!

    @IBOutlet weak var continueButton: MeshSetupButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextField.delegate = self
        continueButton.isEnabled = validateInput()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inputTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if validateInput() {
            submit()
        }

        return false
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
        inputTextField.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    open func submit() {
        ParticleSpinner.show(view)
        fadeContent()
    }

    internal func fadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 0.5
            self.inputTextField.alpha = 0.5
            self.textLabel.alpha = 0.5
            self.continueButton.alpha = 0.5
        }
    }

    internal func unfadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 1
            self.inputTextField.alpha = 1
            self.textLabel.alpha = 1
            self.continueButton.alpha = 1
        }
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
            ParticleSpinner.hide(self.view)
            self.unfadeContent()

            self.inputTextField.becomeFirstResponder()
            self.inputTextField.selectedTextRange = self.inputTextField.textRange(from: self.inputTextField.beginningOfDocument, to: self.inputTextField.endOfDocument)
        }
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
        self.continueButton.isEnabled = validateInput()
    }
}
