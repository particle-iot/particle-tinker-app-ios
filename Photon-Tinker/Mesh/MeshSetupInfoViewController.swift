//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupInfoViewController: MeshSetupViewController {

    @IBOutlet weak var titleLabel: MeshLabel!

    @IBOutlet var textLabels: [MeshLabel]!
    @IBOutlet var textLabelValues: [String]!

    @IBOutlet weak var continueButton: MeshSetupButton!

    internal var setupMesh:Bool?
    internal var callback: (() -> ())!

    func setup(didFinishScreen: @escaping () -> (), setupMesh:Bool?, networkName: String? = nil, deviceType: ParticleDeviceType? = nil, deviceName: String? = nil) {
        self.callback = didFinishScreen

        self.networkName = networkName
        self.deviceType = deviceType
        self.deviceName = deviceName

        self.setupMesh = setupMesh
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        for label in textLabels {
            label.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addFadableViews()
    }

    private func addFadableViews() {
        if viewsToFade == nil {
            viewsToFade = [UIView]()
        }

        viewsToFade!.append(titleLabel)
        viewsToFade!.append(continueButton)

        for textField in self.textLabels {
            viewsToFade!.append(textField)
        }
    }

    internal func setLabelValues() {
        let tfCount = textLabels.count
        let valueCount = textLabelValues.count

        for i in 0 ..< valueCount {
            textLabels[i].isHidden = false
            textLabels[i].text = textLabelValues[i]
        }

        //hide excessive text fields
        for i in valueCount ..< tfCount {
            textLabels[i].isHidden = true
        }
    }

    @IBAction func continuePressed(_ sender: Any) {
        self.fade()

        callback()
    }

}
