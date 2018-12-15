//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFirmwareUpdateProgressViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!

    @IBOutlet weak var textLabel: MeshLabel!

    @IBOutlet weak var noteTitleLabel: MeshLabel!
    @IBOutlet weak var noteTextLabel: MeshLabel!

    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!

    private var progress: Int = 0
    private var file: Int = 1

    internal var callback: (() -> ())!

    override var allowBack: Bool {
        return false
    }

    func setup(didFinishScreen: @escaping () -> ()) {
        self.callback = didFinishScreen
    }

    override func viewWillAppear(_ animated: Bool) {
        successView.isHidden = true
        activityView.startAnimating()

        super.viewWillAppear(animated)
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.PrimaryTextColor)

        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        progressBarView.progressTintColor = MeshSetupStyle.ProgressBarProgressColor
        progressBarView.trackTintColor = MeshSetupStyle.ProgressBarTrackColor
        activityView.color = MeshSetupStyle.NetworkScanActivityIndicatorColor
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.UpdateFirmwareProgress.Title
        noteTextLabel.text = MeshSetupStrings.UpdateFirmwareProgress.NoteText
        noteTitleLabel.text = MeshSetupStrings.UpdateFirmwareProgress.NoteTitle

        successTitleLabel.text = MeshSetupStrings.UpdateFirmwareProgress.SuccessTitle
        successTextLabel.text = MeshSetupStrings.UpdateFirmwareProgress.SuccessText

        setProgress(progress: progress)
    }

    func setFileComplete() {
        var textValue = MeshSetupStrings.UpdateFirmwareProgress.TextInstalling
        textValue = textValue.replacingOccurrences(of: "{0}", with: String(file))


        DispatchQueue.main.async {
            self.activityView.alpha = 1

            self.progressBarView.alpha = 0

            self.textLabel.text = textValue
        }

        self.file += 1
    }

    func setProgress(progress: Int) {
        self.progress = progress

        var textValue = MeshSetupStrings.UpdateFirmwareProgress.Text
        textValue = textValue.replacingOccurrences(of: "{0}", with: String(file))
        textValue = textValue.replacingOccurrences(of: "{1}", with: String(progress))

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
