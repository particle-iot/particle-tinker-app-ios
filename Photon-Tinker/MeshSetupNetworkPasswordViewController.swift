//
//  MeshSetupNetworkPasswordViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupNetworkPasswordViewController: MeshSetupViewController, Storyboardable, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!
    
    @IBOutlet weak var passwordTextField: MeshTextField!

    @IBOutlet weak var continueButton: MeshSetupButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self

        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor
    }

    internal var networkName: String!
    internal var callback: ((String) -> ())?

    func setup(didEnterPassword: @escaping (String) -> (), networkName: String) {
        self.callback = didEnterPassword
        self.networkName = networkName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        validateInput()
        setContent()
    }

    open func setContent() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.ExistingNetworkPassword.Title

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.text = MeshSetupStrings.ExistingNetworkPassword.Text

        continueButton.setTitle(MeshSetupStrings.ExistingNetworkPassword.Button.uppercased(), for: .normal)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        passwordTextField.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        replaceMeshSetupStringTemplates(view: self.view, networkName: self.networkName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passwordTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if validateInput() {
            submit()
        }

        return false
    }

    private func submit() {
        ParticleSpinner.show(view)

        fadeContent()

        callback!(self.passwordTextField.text!)
    }

    private func fadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 0.5
            self.passwordTextField.alpha = 0.5
            self.textLabel.alpha = 0.5
            self.continueButton.alpha = 0.5
        }
    }

    private func unfadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 1
            self.passwordTextField.alpha = 1
            self.textLabel.alpha = 1
            self.continueButton.alpha = 1
        }
    }

    private func validateInput() -> Bool {
        if let text = passwordTextField.text, text.count >= 6 {
            continueButton.isEnabled = true
        } else {
            continueButton.isEnabled = false
        }

        return continueButton.isEnabled
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        self.view.endEditing(true)

        if validateInput() {
            submit()
        }
    }

    func setWrongPassword() {
        DispatchQueue.main.async {
            ParticleSpinner.hide(self.view)
            self.unfadeContent()

            self.passwordTextField.becomeFirstResponder()
            self.passwordTextField.selectedTextRange = self.passwordTextField.textRange(from: self.passwordTextField.beginningOfDocument, to: self.passwordTextField.endOfDocument)
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        validateInput()
    }
    

}
