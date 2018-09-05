//
//  MeshSetupNetworkPasswordViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupNetworkPasswordViewController: MeshSetupViewController, UITextFieldDelegate {
    
    
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var networkPasswordTextField: UITextField!
//    @IBAction func joinNetworkButtonTapped(_ sender: Any) {
//        self.textFieldDidEndEditing(self.networkPasswordTextField)
//    }
//
//    @IBOutlet weak var joinButton: UIButton!
//
//    override func viewDidAppear(_ animated: Bool) {
//        self.networkPasswordTextField.becomeFirstResponder()
//        self.networkPasswordTextField.delegate = self
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        textField.resignFirstResponder()
//        if let pwd = textField.text {
//            if pwd.count < 6 {
//                // TODO: enforce more things ?
//                self.flowError(error: "Network Password must be 6 characters or more", severity: .Warning, action: .Dialog)
//            } else {
//                ParticleSpinner.show(self.view)
//                self.flowManager!.networkPassword = pwd
//                self.joinButton.isEnabled = false
//                self.joinButton.alpha = 0.5
//            }
//        }
//    }
//
//    override func authSuccess() {
//        DispatchQueue.main.async {
//            ParticleSpinner.hide(self.view)
//            self.performSegue(withIdentifier: "joiningNetwork", sender: self)
//        }
//    }
//
//    override func flowError(error: String, severity: MeshSetupErrorSeverity, action: MeshSetupErrorAction) {
//
//        DispatchQueue.main.async {
//            ParticleSpinner.hide(self.view)
//            self.joinButton.isEnabled = true
//            self.joinButton.alpha = 1.0
//            self.networkPasswordTextField.selectAll(self)
//            self.networkPasswordTextField.becomeFirstResponder()
//        }
//
//        super.flowError(error: error, severity: severity, action: action)
//
//    }
    
}
