//
//  MeshSetupJoiningNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/23/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupJoiningNetworkViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var joiningView: UIView!
    @IBOutlet weak var joiningTitleLabel: MeshLabel!
    @IBOutlet weak var joiningIndicator: UIActivityIndicatorView!
    @IBOutlet weak var joiningTextLabel1: MeshLabel!
    @IBOutlet weak var joiningTextLabel2: MeshLabel!
    @IBOutlet weak var joiningTextLabel3: MeshLabel!
    
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!
    
    internal var callback: (() -> ())!

    func setup(didFinishScreen: @escaping () -> (), networkName: String, deviceType: ParticleDeviceType!) {
        self.callback = didFinishScreen
        self.networkName = networkName
        self.deviceType = deviceType
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        joiningTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        joiningIndicator.color = MeshSetupStyle.PairingActivityIndicatorColor

        joiningTextLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        joiningTextLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        joiningTextLabel3.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.JoiningNetwork.SuccessTitle
        successTextLabel.text = MeshSetupStrings.JoiningNetwork.SuccessText

        joiningTitleLabel.text = MeshSetupStrings.JoiningNetwork.Title
        joiningTextLabel1.text = MeshSetupStrings.JoiningNetwork.Text1
        joiningTextLabel2.text = MeshSetupStrings.JoiningNetwork.Text2
        joiningTextLabel3.text = MeshSetupStrings.JoiningNetwork.Text3
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .JoiningNetworkStep1Done:
                    self.joiningTextLabel1.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                    self.joiningTextLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                case .JoiningNetworkStep2Done:
                    self.joiningTextLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                    self.joiningTextLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                case .JoiningNetworkCompleted:
                    self.setSuccess()
                default:
                    fatalError("this should never happen")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        successView.isHidden = true
        joiningIndicator.startAnimating()
    }


    private func setSuccess() {
        DispatchQueue.main.async {
            self.joiningIndicator.stopAnimating()
            self.joiningView.isHidden = true

            self.successView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                [weak self] in
                if let callback = self?.callback {
                    callback()
                }
            }
        }
    }


}
