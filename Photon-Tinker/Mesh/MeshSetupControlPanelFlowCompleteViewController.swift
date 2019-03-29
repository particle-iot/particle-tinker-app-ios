//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupControlPanelFlowCompleteViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!

    internal var action: MeshSetupControlPanelCellType!
    internal var callback: (() -> ())!
    override var allowBack: Bool {
        get {
            return false
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(didFinishScreen: @escaping () -> (), deviceType: ParticleDeviceType?, deviceName: String, action: MeshSetupControlPanelCellType) {
        self.callback = didFinishScreen
        self.deviceType = deviceType
        self.deviceName = deviceName
        self.action = action
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSuccess()
    }

    override func setContent() {
        switch action! {
            case .actionNewWifi:
                self.successTitleLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.AddNewWifi.Title
                self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.AddNewWifi.Text
            default:
                break
        }
    }

    func setSuccess() {
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                [weak self] in
                if let callback = self?.callback {
                    callback()
                }
            }
        }
    }
}
