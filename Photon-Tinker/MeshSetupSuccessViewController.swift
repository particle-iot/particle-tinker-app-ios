//
//  MeshSetupSuccessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupSuccessViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!
    
    
    @IBOutlet weak var setupAnotherLabel: MeshLabel!
    @IBOutlet weak var setupAnotherButton: MeshSetupButton!
    
    @IBOutlet weak var doneLabel: MeshLabel!
    @IBOutlet weak var doneButton: MeshSetupButton!
    
    @IBOutlet var splitterView: UIView!

    private var callback: ((Bool) -> ())!

    func setup(didSelectToAddOneMore: @escaping (Bool) -> (), deviceName: String) {
        self.callback = didSelectToAddOneMore
        self.deviceName = deviceName
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        setupAnotherLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        setupAnotherButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        doneLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        doneButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.Success.SuccessTitle
        successTextLabel.text = MeshSetupStrings.Success.SuccessText

        setupAnotherLabel.text = MeshSetupStrings.Success.SetupAnotherLabel
        setupAnotherButton.setTitle(MeshSetupStrings.Success.SetupAnotherButton, for: .normal)

        doneLabel.text = MeshSetupStrings.Success.DoneLabel
        doneButton.setTitle(MeshSetupStrings.Success.DoneButton, for: .normal)
    }

    @IBAction func setupAnotherButtonTapped(_ sender: Any) {
        callback(true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        callback(false)
    }

}
