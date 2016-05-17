//
//  DeviceVariableTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class DeviceVariableTableViewCell: UITableViewCell {

    var device : SparkDevice?
    
    @IBAction func readButtonTapped(sender: AnyObject) {
        self.readButton.hidden = true
        self.activityIndicator.startAnimating()
        
        device?.getVariable(self.variableNameLabel!.text!, completion: { (resultObj:AnyObject?, error:NSError?) in
            
            self.readButton.hidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
            } else {
                self.resultLabel.text = resultObj?.stringValue
            }
        })
        
    }
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var variableNameLabel: UILabel!
    @IBOutlet weak var variableTypeString: UILabel!
    
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
}
