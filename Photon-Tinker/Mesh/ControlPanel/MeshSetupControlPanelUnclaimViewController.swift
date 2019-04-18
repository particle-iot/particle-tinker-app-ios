//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelUnclaimViewController : MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!

    private var unclaimCallback: ((Bool) -> ())!

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Unclaim.Title
    }

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(deviceName: String, callback: @escaping (Bool) -> ()) {
        self.deviceName = deviceName
        self.unclaimCallback = callback
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.ExtraLargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.Unclaim.Title
        textLabel.text = MeshSetupStrings.ControlPanel.Unclaim.Text
        continueButton.setTitle(MeshSetupStrings.ControlPanel.Unclaim.UnclaimButton, for: .normal)
    }

    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()
        self.unclaim()
    }


    private func unclaim() {
//        self.device.unclaim() { (error: Error?) -> Void in
//            if let error = error as? NSError {
//                self.showNetworkError(error: error)
//            } else {
//                self.unclaimCallback(true)
//            }
//        }
    }

    internal func showNetworkError(error: NSError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                    message: error.localizedDescription,
                    preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: MeshSetupStrings.Action.Cancel, style: .cancel) { action in
                self.resume(animated: true)
            })

            alert.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                self.unclaim()
            })

            self.present(alert, animated: true)
        }
    }


}
