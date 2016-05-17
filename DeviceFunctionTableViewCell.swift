//
//  DeviceFunctionTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

internal class DeviceFunctionTableViewCell: UITableViewCell {
    
    var device : SparkDevice?
    
    @IBOutlet weak var functionNameLabel: UILabel!
    @IBAction func callButtonTapped(sender: AnyObject) {
        var args = [String]()
        args.append(self.argumentsTextField.text!)
        self.callButton.hidden = true
        self.activityIndicator.startAnimating()
        device?.callFunction(self.functionNameLabel.text!, withArguments: args, completion: { (resultValue :NSNumber?, error: NSError?) in
            self.callButton.hidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
            } else {
                self.resultLabel.text = resultValue?.stringValue
            }
        })
    }
    @IBOutlet weak var argumentsTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var argumentsTitleLabel: UILabel!
//    @IBOutlet weak var centerFunctionNameLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var callButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.argumentsTextField.hidden = !selected
//        self.argumentsTitleLabel.hidden = !selected
//        self.callButton.hidden = !selected
//        self.centerFunctionNameLayoutConstraint.constant = selected ? -20 : 0
    }
    
    
}
