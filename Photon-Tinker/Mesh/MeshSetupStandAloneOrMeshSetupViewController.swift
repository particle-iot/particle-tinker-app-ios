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

    override var allowBack: Bool {
        return false
    }

    func setup(setupMesh: @escaping (Bool) -> (), deviceType: ParticleDeviceType?) {
        self.callback = setupMesh
        self.deviceType = deviceType
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        meshButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
        standaloneButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.StandAloneOrMeshSetup.Title
        textLabel.text = MeshSetupStrings.StandAloneOrMeshSetup.Text

        meshButton.setTitle(MeshSetupStrings.StandAloneOrMeshSetup.MeshButton, for: .normal)
        standaloneButton.setTitle(MeshSetupStrings.StandAloneOrMeshSetup.StandAloneButton, for: .normal)
    }

    @IBAction func meshButtonTapped(_ sender: Any) {
        callback(true)

        ParticleSpinner.show(view)
        fadeContent()
    }

    @IBAction func standAloneButtonTapped(_ sender: Any) {
        callback(false)

        ParticleSpinner.show(view)
        fadeContent()
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        ParticleSpinner.hide(view, animated: animated)
        unfadeContent(animated: animated)
        isBusy = false
    }

    internal func fadeContent() {
        self.isBusy = true
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 0.5
            self.textLabel.alpha = 0.5

            self.meshButton.alpha = 0.5
            self.standaloneButton.alpha = 0.5
        }
    }

    internal func unfadeContent(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.titleLabel.alpha = 1
                self.textLabel.alpha = 1

                self.meshButton.alpha = 1
                self.standaloneButton.alpha = 1
            }
        } else {
            self.titleLabel.alpha = 1
            self.textLabel.alpha = 1

            self.meshButton.alpha = 1
            self.standaloneButton.alpha = 1

            self.view.setNeedsDisplay()
        }
    }
}
