//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit


class Gen3SetupConnectingToInternetEthernetViewController: Gen3SetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "Gen3SetupProgressView"
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

    override func setState(_ state: Gen3SetupFlowState) {
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



class Gen3SetupConnectingToInternetWifiViewController: Gen3SetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "Gen3SetupProgressView"
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

    override func setState(_ state: Gen3SetupFlowState) {
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

class Gen3SetupConnectingToInternetCellularViewController: Gen3SetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "Gen3SetupProgressView"
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

    override func setState(_ state: Gen3SetupFlowState) {
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
