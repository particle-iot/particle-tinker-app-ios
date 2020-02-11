//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit


class MeshSetupConnectingToInternetEthernetViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = Gen3SetupStrings.ConnectingToInternetEthernet.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.ConnectingToInternetEthernet.SuccessText

        progressTitleLabel.text = Gen3SetupStrings.ConnectingToInternetEthernet.Title

        self.progressTextLabelValues = [
            Gen3SetupStrings.ConnectingToInternetEthernet.Text1,
            Gen3SetupStrings.ConnectingToInternetEthernet.Text2
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
        successTitleLabel.text = Gen3SetupStrings.ConnectingToInternetWifi.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.ConnectingToInternetWifi.SuccessText

        progressTitleLabel.text = Gen3SetupStrings.ConnectingToInternetWifi.Title

        self.progressTextLabelValues = [
            Gen3SetupStrings.ConnectingToInternetWifi.Text1,
            Gen3SetupStrings.ConnectingToInternetWifi.Text2
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
        successTitleLabel.text = Gen3SetupStrings.ConnectingToInternetCellular.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.ConnectingToInternetCellular.SuccessText

        progressTitleLabel.text = Gen3SetupStrings.ConnectingToInternetCellular.Title

        self.progressTextLabelValues = [
            Gen3SetupStrings.ConnectingToInternetCellular.Text1,
            Gen3SetupStrings.ConnectingToInternetCellular.Text2,
            Gen3SetupStrings.ConnectingToInternetCellular.Text3
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
