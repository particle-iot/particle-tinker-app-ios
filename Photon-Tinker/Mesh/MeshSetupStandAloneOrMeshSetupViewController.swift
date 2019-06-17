//
// Created by Raimundas Sakalauskas on 16/10/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshSetupStandAloneOrMeshSetupViewController : MeshSetupViewController, Storyboardable {
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!

    @IBOutlet weak var meshButton: MeshSetupButton!
    @IBOutlet weak var standaloneButton: MeshSetupAlternativeButton!

    internal var callback: ((Bool) -> ())!

    func setup(setupMesh: @escaping (Bool) -> (), deviceType: ParticleDeviceType?) {
        self.callback = setupMesh
        self.deviceType = deviceType
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        meshButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
        standaloneButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.StandAloneOrMeshSetup.Title
        textLabel.text = MeshSetupStrings.StandAloneOrMeshSetup.Text

        meshButton.setTitle(MeshSetupStrings.StandAloneOrMeshSetup.MeshButton, for: .normal)
        standaloneButton.setTitle(MeshSetupStrings.StandAloneOrMeshSetup.StandAloneButton, for: .normal)
    }

    @IBAction func meshButtonTapped(_ sender: Any) {
        callback(true)

        self.fade()
    }

    @IBAction func standAloneButtonTapped(_ sender: Any) {
        callback(false)

        self.fade()
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
        viewsToFade!.append(textLabel)
        viewsToFade!.append(meshButton)
        viewsToFade!.append(standaloneButton)
    }



}
