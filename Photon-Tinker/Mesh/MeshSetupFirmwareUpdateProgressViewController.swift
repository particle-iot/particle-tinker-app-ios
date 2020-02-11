//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFirmwareUpdateProgressViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: ParticleLabel!

    @IBOutlet weak var textLabel: ParticleLabel!

    @IBOutlet weak var noteTitleLabel: ParticleLabel!
    @IBOutlet weak var noteTextLabel: ParticleLabel!

    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: ParticleLabel!
    @IBOutlet weak var successTextLabel: ParticleLabel!

    private var progress: Int = 0
    private var file: Int = 1

    internal var callback: (() -> ())!

    func setup(didFinishScreen: @escaping () -> ()) {
        self.callback = didFinishScreen
    }

    override func viewWillAppear(_ animated: Bool) {
        successView.isHidden = true
        activityView.startAnimating()

        super.viewWillAppear(animated)
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: ParticleStyle.PrimaryTextColor)

        successTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        progressBarView.progressTintColor = ParticleStyle.ProgressBarProgressColor
        progressBarView.trackTintColor = ParticleStyle.ProgressBarTrackColor
        activityView.color = ParticleStyle.NetworkScanActivityIndicatorColor
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.UpdateFirmwareProgress.Title
        noteTextLabel.text = Gen3SetupStrings.UpdateFirmwareProgress.NoteText
        noteTitleLabel.text = Gen3SetupStrings.UpdateFirmwareProgress.NoteTitle

        successTitleLabel.text = Gen3SetupStrings.UpdateFirmwareProgress.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.UpdateFirmwareProgress.SuccessText

        setProgress(progress: progress)
    }

    func setFileComplete() {
        var textValue = Gen3SetupStrings.UpdateFirmwareProgress.TextInstalling
        textValue = textValue.replacingOccurrences(of: "{{partIdx}}", with: String(file))


        DispatchQueue.main.async {
            self.activityView.alpha = 1

            self.progressBarView.alpha = 0

            self.textLabel.text = textValue
        }

        self.file += 1
    }

    func setProgress(progress: Int) {
        self.progress = progress

        var textValue = Gen3SetupStrings.UpdateFirmwareProgress.Text
        textValue = textValue.replacingOccurrences(of: "{{partIdx}}", with: String(file))
        textValue = textValue.replacingOccurrences(of: "{{progress}}", with: String(progress))

        DispatchQueue.main.async {
            self.activityView.alpha = 0

            self.progressBarView.alpha = 100
            self.progressBarView.progress = Float(progress)/100

            self.textLabel.text = textValue
        }
    }


    func setFirmwareUpdateComplete() {
        DispatchQueue.main.async {

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
