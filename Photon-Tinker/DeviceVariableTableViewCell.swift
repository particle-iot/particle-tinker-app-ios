//
//  DeviceVariableTableViewCell.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 05/16/19.
//  Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol DeviceVariableTableViewCellDelegate: class  {
    func tappedOnVariableValue(_ sender : DeviceVariableTableViewCell, name : String, value : String)
    func tappedOnVariableName(_ sender : DeviceVariableTableViewCell, name : String)
}

internal class DeviceVariableTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var valueButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundShadeView: UIView!

    weak var delegate : DeviceVariableTableViewCellDelegate?

    var variableName : String!
    var variableValue : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundShadeView.layer.cornerRadius = 6
        self.backgroundShadeView.layer.masksToBounds = true
    }

    func setup(variableName: String, variableType: String, variableValue: String?) {
        self.variableName = variableName

        self.nameLabel.text = variableName
        self.typeLabel.text = "(\(variableType))"
        self.setVariableValue(value: variableValue)
    }

    func setVariableValue(value: String?) {
        self.stopUpdating()

        if let value = value {
            self.variableValue = value
            self.valueLabel.text = value
            self.valueButton.isUserInteractionEnabled = true
        } else {
            self.variableValue = nil
            self.valueLabel.text = TinkerStrings.Variables.CellNotLoadedLabel
            self.valueButton.isUserInteractionEnabled = false
        }
    }

    func setVariableError() {
        self.stopUpdating()

        self.variableValue = nil
        self.valueLabel.text = TinkerStrings.Variables.CellErrorLabel
        self.valueButton.isUserInteractionEnabled = false
    }

    func startUpdating() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        self.nameButton.isUserInteractionEnabled = false

        self.valueLabel.isHidden = !self.activityIndicator.isHidden
    }

    func stopUpdating() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()

        self.nameButton.isUserInteractionEnabled = true

        self.valueLabel.isHidden = !self.activityIndicator.isHidden
    }



    @IBAction func nameButtonTapped(_ sender: AnyObject) {
        self.delegate?.tappedOnVariableName(self, name: self.variableName!)

        self.startUpdating()
    }

    @IBAction func valueButtonTapped(_ sender: AnyObject) {
        self.delegate?.tappedOnVariableValue(self, name: self.variableName!, value: self.variableValue!)
    }
}
