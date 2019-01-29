//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit


class MeshSetupConnectingToInternetEthernetViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.ConnectingToInternetEthernet.SuccessTitle
        successTextLabel.text = MeshSetupStrings.ConnectingToInternetEthernet.SuccessText

        progressTitleLabel.text = MeshSetupStrings.ConnectingToInternetEthernet.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.ConnectingToInternetEthernet.Text1,
            MeshSetupStrings.ConnectingToInternetEthernet.Text2
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .TargetDeviceConnectingToInternetStarted:
                    self.setStep(0)
                case .TargetDeviceConnectingToInternetStep1Done:
                    self.setStep(1)
                case .TargetDeviceConnectingToInternetCompleted:
                    self.setStep(2)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}



class MeshSetupConnectingToInternetWifiViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.ConnectingToInternetWifi.SuccessTitle
        successTextLabel.text = MeshSetupStrings.ConnectingToInternetWifi.SuccessText

        progressTitleLabel.text = MeshSetupStrings.ConnectingToInternetWifi.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.ConnectingToInternetWifi.Text1,
            MeshSetupStrings.ConnectingToInternetWifi.Text2
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .TargetDeviceConnectingToInternetStarted:
                    self.setStep(0)
                case .TargetDeviceConnectingToInternetStep1Done:
                    self.setStep(1)
                case .TargetDeviceConnectingToInternetCompleted:
                    self.setStep(2)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}

class MeshSetupConnectingToInternetCellularViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.ConnectingToInternetCellular.SuccessTitle
        successTextLabel.text = MeshSetupStrings.ConnectingToInternetCellular.SuccessText

        progressTitleLabel.text = MeshSetupStrings.ConnectingToInternetCellular.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.ConnectingToInternetCellular.Text1,
            MeshSetupStrings.ConnectingToInternetCellular.Text2,
            MeshSetupStrings.ConnectingToInternetCellular.Text3
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .TargetDeviceConnectingToInternetStarted:
                    self.setStep(0)
                case .TargetDeviceConnectingToInternetStep1Done:
                    self.setStep(1)
                case .TargetDeviceConnectingToInternetStep2Done:
                    self.setStep(2)
                case .TargetDeviceConnectingToInternetCompleted:
                    self.setStep(3)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
