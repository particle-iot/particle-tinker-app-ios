//
//  DeviceVariableTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 particle. All rights reserved.
//

import Foundation

protocol DeviceVariableTableViewCellDelegate  {
    func tappedOnVariable(_ sender : DeviceVariableTableViewCell, name : String, value : String)
}

internal class DeviceVariableTableViewCell: DeviceDataTableViewCell {

    var variableType : String? {
        didSet {
            self.variableTypeButton.setTitle(" ("+self.variableType!+")", for: UIControlState())
        }
    }
    
    var delegate : DeviceVariableTableViewCellDelegate?
    
    var tap : UITapGestureRecognizer?
    var variableValue : String?
    var variableName : String? {
        didSet {
            if variableName == "" {
                self.noVarsLabel.isHidden = false
                self.variableTypeButton.isHidden = true
                self.variableNameButton.isHidden = true
                self.resultLabel.isHidden = true
                self.bkgView.backgroundColor = UIColor.white
                if let t = tap {
                    self.resultLabel.removeGestureRecognizer(t)
                }
                self.tap = nil
                
            } else {
                self.variableNameButton.setTitle(" "+variableName!, for: UIControlState())
                self.noVarsLabel.isHidden = true
                self.variableTypeButton.isHidden = false
                self.variableNameButton.isHidden = false
                self.resultLabel.isHidden = false
                self.resultLabel.isUserInteractionEnabled = true
                self.bkgView.backgroundColor = ParticleUtils.particleAlmostWhiteColor

                self.tap = UITapGestureRecognizer(target: self, action: #selector(DeviceVariableTableViewCell.variableLabelAction(_:)))
                tap!.delegate = self


            }
        }
    }
    @IBAction func readButtonTapped(_ sender: AnyObject) {

        
        self.activityIndicator.startAnimating()
        SEGAnalytics.shared().track("Device Inspector: variable read")
        self.resultLabel.isHidden = true
        self.device?.getVariable(variableName!, completion: { (resultObj:Any?, error:Error?) in
            
            self.resultLabel.isHidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
                if let t = self.tap {
                    self.resultLabel.removeGestureRecognizer(t)
                }
                
                
            } else {
                if let r = resultObj {
                    
                    if let resultValue = r as? String {
                        self.variableValue = resultValue
                    } else if let resultValue = r as? NSNumber {
                        self.variableValue = resultValue.stringValue
                    }
                    
                    self.resultLabel.text = self.variableValue
                    self.resultLabel.addGestureRecognizer(self.tap!)
                    
                    // Receive action
                }
                
            }
        })
        
    }
    
    
    func variableLabelAction(_ sender : UITapGestureRecognizer)
    {
        self.delegate?.tappedOnVariable(self, name: self.variableName!, value: self.variableValue!)
    }

    
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var noVarsLabel: UILabel!
    @IBOutlet weak var variableNameButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var variableTypeButton: UIButton!
    
    @IBOutlet weak var bkgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 6
        self.bkgView.layer.masksToBounds = true
        
        // Initialization code
    }

}
