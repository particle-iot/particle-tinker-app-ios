//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit



class MeshSetupBillingInfoViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!

    @IBOutlet weak var textLabel1: MeshLabel!
    @IBOutlet weak var textLabel2: MeshLabel!
    @IBOutlet weak var textLabel3: MeshLabel!

    @IBOutlet weak var noteLabel: MeshLabel!

    @IBOutlet weak var continueButton: MeshSetupButton!
    
    internal var callback: (() -> ())!

    func setup(didPressContinue: @escaping () -> ()) {
        self.callback = didPressContinue
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel3.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        noteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }


    override func setContent() {
        titleLabel.text = MeshSetupStrings.BillingInfo.Title
        textLabel1.text = MeshSetupStrings.BillingInfo.Text1
        textLabel2.text = MeshSetupStrings.BillingInfo.Text2
        textLabel3.text = MeshSetupStrings.BillingInfo.Text3
        noteLabel.text = MeshSetupStrings.BillingInfo.Note

        continueButton.setTitle(MeshSetupStrings.BillingInfo.Button, for: .normal)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        callback()
    }

}
