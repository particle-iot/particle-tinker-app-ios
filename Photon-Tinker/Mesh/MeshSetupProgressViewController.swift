//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
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

    func setup(didFinishScreen: @escaping () -> (), networkName: String? = nil, deviceType: ParticleDeviceType? = nil, deviceName: String? = nil) {
        self.callback = didFinishScreen
        self.networkName = networkName
        self.deviceType = deviceType
        self.deviceName = deviceName
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
        let tfCount = progressTextLabels.count
        let valueCount = progressTextLabelValues.count


        for i in 0 ..< valueCount {
            progressTextLabels[i].isHidden = false
            progressTextLabels[i].text = progressTextLabelValues[i]
        }

        //hide excessive text fields
        for i in valueCount ..< tfCount {
            progressTextLabels[i].isHidden = true
        }
    }

    func setStep(_ step:Int) {
        NSLog("step = \(step) progressTextLabels.count: \(progressTextLabels.count) progressTextLabelValues.count: \(progressTextLabelValues.count)")
        if (step == progressTextLabelValues.count) {
            setSuccess()
        } else {
            for i in 0 ..< progressTextLabelValues.count {
                if (i < step) {
                    progressTextLabels[i].setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                } else if i == step {
                    progressTextLabels[i].setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
                } else {
                    progressTextLabels[i].setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
                }
            }
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
