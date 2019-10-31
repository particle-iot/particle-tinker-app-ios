//
//  DeviceFunctionTableViewCell.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 05/16/19.
//  Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol DeviceFunctionTableViewCellDelegate: class  {
    func tappedOnFunctionName(_ sender : DeviceFunctionTableViewCell, name : String, argument: String)
    func tappedOnExpandButton(_ sender : DeviceFunctionTableViewCell)
    func updateArgument(_ sender: DeviceFunctionTableViewCell, argument: String)
}

internal class DeviceFunctionTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var backgroundShadeView: UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var expandIndicator: UIImageView!

    @IBOutlet weak var argumentsTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!

    weak var delegate : DeviceFunctionTableViewCellDelegate?
    var functionName : String!

    func setup(functionName: String) {
        self.functionName = functionName
        self.nameLabel.text = self.functionName

        self.resultLabel.text = ""
        if (self.isSelected) {
            self.expandIndicator.transform = CGAffineTransform(rotationAngle: .pi)
        } else {
            self.expandIndicator.transform = CGAffineTransform.identity
        }
        self.expandButton.isUserInteractionEnabled = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundShadeView.layer.cornerRadius = 6
        self.backgroundShadeView.layer.masksToBounds = true

        self.argumentsTextField.delegate = self
    }

    func expandAnim() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.expandIndicator.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: { [weak self] done in
            self?.argumentsTextField.becomeFirstResponder()
        })
    }

    func collapseAnim() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.expandIndicator.transform = CGAffineTransform.identity
        })
    }


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.callButtonTapped(self)

        textField.selectAll(nil)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.updateArgument(self, argument: textField.text ?? "")
    }

    func setFunctionValue(value: String?) {
        self.stopUpdating()

        if let value = value {
            self.resultLabel.text = value
        } else {
            self.resultLabel.text = ""
        }
    }

    func setFunctionError() {
        self.stopUpdating()

        self.resultLabel.text = TinkerStrings.Functions.CellErrorLabel
    }

    func startUpdating() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        self.callButton.isUserInteractionEnabled = false
        self.resultLabel.isHidden = !self.activityIndicator.isHidden
    }

    func stopUpdating() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()

        self.callButton.isUserInteractionEnabled = true

        self.resultLabel.isHidden = !self.activityIndicator.isHidden
    }

    @IBAction func callButtonTapped(_ sender: AnyObject) {
        self.delegate?.tappedOnFunctionName(self, name: self.functionName, argument: self.argumentsTextField.text ?? "")

        self.startUpdating()
    }

    @IBAction func expandTapped(_ sender: AnyObject) {
        if (self.isSelected) {
            self.collapseAnim()
        } else {
            self.expandAnim()
        }
        self.delegate?.tappedOnExpandButton(self)
    }


}
