//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupPairingView"
    }

    @IBOutlet weak var pairingView: UIView!
    @IBOutlet weak var pairingTextLabel: MeshLabel!
    @IBOutlet weak var pairingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!

    internal var callback: (() -> ())!

    func setup(didFinishScreen: @escaping () -> (), deviceType: ParticleDeviceType?, deviceName: String) {
        self.callback = didFinishScreen
        self.deviceType = deviceType
        self.deviceName = deviceName
    }

    override func setStyle() {
        pairingIndicator.color = ParticleStyle.PairingActivityIndicatorColor

        pairingTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        successTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        successView.isHidden = true
        pairingIndicator.startAnimating()

        super.viewWillAppear(animated)
    }

    override func setContent() {
        pairingTextLabel.text = MeshSetupStrings.Pairing.PairingText
        successTitleLabel.text = MeshSetupStrings.Pairing.SuccessTitle
        successTextLabel.text = MeshSetupStrings.Pairing.SuccessText
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
