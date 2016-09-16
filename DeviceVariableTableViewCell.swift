//
//  DeviceVariableTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

protocol DeviceVariableTableViewCellDelegate  {
    func tappedOnVariable(sender : DeviceVariableTableViewCell, name : String, value : String)
}

internal class DeviceVariableTableViewCell: DeviceDataTableViewCell {

    var variableType : String? {
        didSet {
            self.variableTypeButton.setTitle(" ("+self.variableType!+")", forState: .Normal)
        }
    }
    
    var delegate : DeviceVariableTableViewCellDelegate?
    
    var tap : UITapGestureRecognizer?
    var variableValue : String?
    var variableName : String? {
        didSet {
            if variableName == "" {
                self.noVarsLabel.hidden = false
                self.variableTypeButton.hidden = true
                self.variableNameButton.hidden = true
                self.resultLabel.hidden = true
                self.bkgView.backgroundColor = UIColor.whiteColor()
                if let t = tap {
                    self.resultLabel.removeGestureRecognizer(t)
                }
                self.tap = nil
                
            } else {
                self.variableNameButton.setTitle(" "+variableName!, forState: .Normal)
                self.noVarsLabel.hidden = true
                self.variableTypeButton.hidden = false
                self.variableNameButton.hidden = false
                self.resultLabel.hidden = false
                self.resultLabel.userInteractionEnabled = true
                self.bkgView.backgroundColor = ParticleUtils.particleAlmostWhiteColor

                self.tap = UITapGestureRecognizer(target: self, action: #selector(DeviceVariableTableViewCell.variableLabelAction(_:)))
                tap!.delegate = self


            }
        }
    }
    @IBAction func readButtonTapped(sender: AnyObject) {

        
        self.activityIndicator.startAnimating()
        SEGAnalytics.sharedAnalytics().track("Device Inspector: variable read")
        self.resultLabel.hidden = true
        self.device?.getVariable(variableName!, completion: { (resultObj:AnyObject?, error:NSError?) in
            
            self.resultLabel.hidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
                if let t = self.tap {
                    self.resultLabel.removeGestureRecognizer(t)
                }
                
                
            } else {
                if let r = resultObj {
                    
                    self.variableValue = r.description
                    self.resultLabel.text = self.variableValue
                    self.resultLabel.addGestureRecognizer(self.tap!)
                    
                    // Receive action
                }
                
            }
        })
        
    }
    
    
    func variableLabelAction(sender : UITapGestureRecognizer)
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
