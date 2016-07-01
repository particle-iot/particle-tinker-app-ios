//
//  DeviceVariableTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

internal class DeviceVariableTableViewCell: DeviceDataTableViewCell {

    var variableType : String? {
        didSet {
            self.variableTypeButton.setTitle(" ("+self.variableType!+")", forState: .Normal)
        }
    }
    
    var variableName : String? {
        didSet {
            if variableName == "" {
                self.noVarsLabel.hidden = false
                self.variableTypeButton.hidden = true
                self.variableNameButton.hidden = true
                self.resultLabel.hidden = true
            } else {
                self.variableNameButton.setTitle(" "+variableName!, forState: .Normal)
            }
        }
    }
    @IBAction func readButtonTapped(sender: AnyObject) {

        self.activityIndicator.startAnimating()
        self.resultLabel.hidden = true
        self.device?.getVariable(variableName!, completion: { (resultObj:AnyObject?, error:NSError?) in
            
            self.resultLabel.hidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
            } else {
                self.resultLabel.text = resultObj?.stringValue
            }
        })
        
    }
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var noVarsLabel: UILabel!
    @IBOutlet weak var variableNameButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var variableTypeButton: UIButton!
    
    @IBOutlet weak var bkgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 4
        self.bkgView.layer.masksToBounds = true
        
        // Initialization code
    }

}
