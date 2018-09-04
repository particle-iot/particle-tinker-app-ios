//
//  MeshSetupNameDeviceViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupNameDeviceViewController: MeshSetupViewController, UITextFieldDelegate {

    
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.deviceNameTextField.becomeFirstResponder()
        self.deviceNameTextField.delegate = self
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        if let name = textField.text {
            if name.count < 1 {
                // TODO: enforce more things ?
                self.flowError(error: "Device name must be 1 characters or more", severity: .Warning, action: .Dialog)
            } else {
                ParticleSpinner.show(self.view)
                self.flowManager!.deviceName = name
                self.doneButton.isEnabled = false
                self.doneButton.alpha = 0.5
            }
        }
    }
    
    override func deviceNamed() {
        DispatchQueue.main.async {
            ParticleSpinner.hide(self.view)
            self.performSegue(withIdentifier: "success", sender: self)
        }
    }
    
    override func flowError(error: String, severity: MeshSetupErrorSeverity, action: MeshSetupErrorAction) {
        DispatchQueue.main.async {
            self.doneButton.isEnabled = true
            self.doneButton.alpha = 1.0
        }
        
        super.flowError(error: error, severity: severity, action: action)
        
    }

    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.textFieldDidEndEditing(self.deviceNameTextField)
    }
}
