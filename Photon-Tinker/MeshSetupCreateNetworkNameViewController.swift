//
//  MeshSetupNetworkPasswordViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupCreateNetworkNameViewController: MeshSetupTextInputViewController, Storyboardable{

    internal var callback: ((String) -> ())!

    func setup(didEnterNetworkName: @escaping (String) -> ()) {
        self.callback = didEnterNetworkName
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.CreateNetworkName.Title
        textLabel.text = MeshSetupStrings.CreateNetworkName.Text
        continueButton.setTitle(MeshSetupStrings.CreateNetworkName.Button, for: .normal)
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
}
