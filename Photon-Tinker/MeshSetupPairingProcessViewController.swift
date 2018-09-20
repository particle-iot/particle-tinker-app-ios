//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, Storyboardable {
  
    @IBOutlet weak var pairingView: UIView!
    @IBOutlet weak var pairingTextLabel: MeshLabel!
    @IBOutlet weak var pairingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!

    private var callback: (() -> ())!
    private var deviceType: ParticleDeviceType!
    private var deviceName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor
        pairingIndicator.color = MeshSetupStyle.PairingActivityIndicatorColor

        successView.isHidden = true
    }

    func setup(didFinishScreen: @escaping () -> (), deviceType: ParticleDeviceType, deviceName: String) {
        self.callback = didFinishScreen
        self.deviceType = deviceType
        self.deviceName = deviceName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pairingIndicator.startAnimating()

        pairingTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        pairingTextLabel.text = MeshSetupStrings.Pairing.PairingText

        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTitleLabel.text = MeshSetupStrings.Pairing.SuccessTitle

        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.text = MeshSetupStrings.Pairing.SuccessText

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description, deviceName: self.deviceName)
    }

    func setSuccess() {
        DispatchQueue.main.async {
            self.pairingIndicator.stopAnimating()
            self.pairingView.isHidden = true

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
