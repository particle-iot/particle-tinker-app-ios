//
//  DeviceFunctionTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 particle. All rights reserved.
//

import Foundation

internal class DeviceFunctionTableViewCell: DeviceDataTableViewCell, UITextFieldDelegate {
    
    var functionName : String? {
        didSet {
            if self.functionName == "" {
                self.noFunctionsLabel.isHidden = false
                self.functionNameButton.isHidden = true
                self.argumentsButton.isHidden = true
                self.bkgView.backgroundColor = UIColor.white
                self.resultLabel.isHidden = true
            } else {
                self.functionNameButton.setTitle(self.functionName!+"  ", for: UIControlState())
                self.noFunctionsLabel.isHidden = true
                self.functionNameButton.isHidden = false
                self.argumentsButton.isHidden = false
                self.resultLabel.isHidden = false
                self.bkgView.backgroundColor = ParticleUtils.particleAlmostWhiteColor
            }
        }
    }

    @IBOutlet weak var noFunctionsLabel: UILabel!
    @IBAction func callButtonTapped(_ sender: AnyObject) {
        var args = [String]()
        SEGAnalytics.shared().track("DeviceInspector_FunctionCalled")
        args.append(self.argumentsTextField.text!)
        self.resultLabel.isHidden = true
        self.activityIndicator.startAnimating()
        self.device?.callFunction(self.functionName!, withArguments: args, completion: { (resultValue :NSNumber?, error: Error?) in
            self.resultLabel.isHidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
            } else {
                self.resultLabel.text = resultValue?.stringValue
            }
        })
    }
    
    @IBOutlet weak var argumentsButton: UIButton!
    @IBOutlet weak var functionNameButton: UIButton!
    @IBOutlet weak var argumentsTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 6
        self.bkgView.layer.masksToBounds = true
        
        self.argumentsTextField.delegate = self
        

        // Initialization code
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.setSelected(true, animated: true)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        self.callButtonTapped(textField)
        textField.selectAll(nil)
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.argumentsTextField.hidden = !selected
//        self.argumentsTitleLabel.hidden = !selected
//        self.callButton.hidden = !selected
//        self.centerFunctionNameLayoutConstraint.constant = selected ? -20 : 0
    }
    
    
    @IBOutlet weak var bkgView: UIView!
    
    
    @IBAction func argumentsButtonTapped(_ sender: AnyObject) {
        self.setSelected(!self.isSelected, animated: true)
    }
    
}
