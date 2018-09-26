//
//  MeshSetupJoiningNetworkViewController.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 9/26/18.
//  Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupProgressViewController: MeshSetupViewController {

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressTitleLabel: MeshLabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!

    @IBOutlet var progressTextLabels: [MeshLabel]!
    @IBOutlet var progressTextLabelValues: [String]!

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!
    
    internal var callback: (() -> ())!

    internal var currentStep = 0

    func setup(didFinishScreen: @escaping () -> (), networkName: String? = nil, deviceType: ParticleDeviceType? = nil, deviceName: String? = nil) {
        self.callback = didFinishScreen
        self.networkName = networkName
        self.deviceType = deviceType
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        progressTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        progressIndicator.color = MeshSetupStyle.ProgressActivityIndicatorColor

        let first = progressTextLabels.first!
        first.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        for label in progressTextLabels {
            if (label != first) {
                label.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
            }
        }
    }

    internal func setProgressLabelValues() {
        guard progressTextLabels.count == progressTextLabelValues.count else {
            fatalError("missing labels or label values")
        }

        for i in 0 ..< progressTextLabels.count {
            progressTextLabels[i].text = progressTextLabelValues[i]
        }
    }

    func advance() {
        if (currentStep == progressTextLabels.count-1) {
            setSuccess()
        } else {
            progressTextLabels[currentStep].setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            currentStep += 1
            progressTextLabels[currentStep].setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        successView.isHidden = true
        progressIndicator.startAnimating()
    }


    private func setSuccess() {
        DispatchQueue.main.async {
            self.progressIndicator.stopAnimating()
            self.progressView.isHidden = true

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
