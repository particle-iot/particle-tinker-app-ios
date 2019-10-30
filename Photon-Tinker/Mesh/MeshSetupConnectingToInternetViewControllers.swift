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
        successTitleLabel.text = MeshStrings.ConnectingToInternetEthernet.SuccessTitle
        successTextLabel.text = MeshStrings.ConnectingToInternetEthernet.SuccessText

        progressTitleLabel.text = MeshStrings.ConnectingToInternetEthernet.Title

        self.progressTextLabelValues = [
            MeshStrings.ConnectingToInternetEthernet.Text1,
            MeshStrings.ConnectingToInternetEthernet.Text2
        ]

        setProgressLabelValues()
    }

    override func setState(_ state: MeshSetupFlowState) {
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
        successTitleLabel.text = MeshStrings.ConnectingToInternetWifi.SuccessTitle
        successTextLabel.text = MeshStrings.ConnectingToInternetWifi.SuccessText

        progressTitleLabel.text = MeshStrings.ConnectingToInternetWifi.Title

        self.progressTextLabelValues = [
            MeshStrings.ConnectingToInternetWifi.Text1,
            MeshStrings.ConnectingToInternetWifi.Text2
        ]

        setProgressLabelValues()
    }

    override func setState(_ state: MeshSetupFlowState) {
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
        successTitleLabel.text = MeshStrings.ConnectingToInternetCellular.SuccessTitle
        successTextLabel.text = MeshStrings.ConnectingToInternetCellular.SuccessText

        progressTitleLabel.text = MeshStrings.ConnectingToInternetCellular.Title

        self.progressTextLabelValues = [
            MeshStrings.ConnectingToInternetCellular.Text1,
            MeshStrings.ConnectingToInternetCellular.Text2,
            MeshStrings.ConnectingToInternetCellular.Text3
        ]

        setProgressLabelValues()
    }

    override func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .TargetDeviceConnectingToInternetStarted:
                    self.setStep(0)
                case .TargetDeviceConnectingToInternetStep0Done:
                    self.setStep(1)
                case .TargetDeviceConnectingToInternetStep1Done:
                    self.setStep(2)
                case .TargetDeviceConnectingToInternetCompleted:
                    self.setStep(3)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
