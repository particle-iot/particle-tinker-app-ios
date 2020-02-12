//
// Created by Raimundas Sakalauskas on 17/10/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation




class Gen3SetupInfoJoinerViewController: Gen3SetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "Gen3SetupInfoView"
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.JoinerInfo.Title

        self.textLabelValues = [
            Gen3SetupStrings.JoinerInfo.Text1,
            Gen3SetupStrings.JoinerInfo.Text2,
            Gen3SetupStrings.JoinerInfo.Text3
        ]

        continueButton.setTitle(Gen3SetupStrings.JoinerInfo.Button, for: .normal)

        setLabelValues()
    }
}



class Gen3SetupCellularInfoViewController: Gen3SetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "Gen3SetupInfoView"
    }

    internal var simActive:Bool!

    func setup(didFinishScreen: @escaping () -> (), setupMesh:Bool, simActive:Bool, networkName: String? = nil, deviceType: ParticleDeviceType? = nil, deviceName: String? = nil) {
        self.callback = didFinishScreen

        self.networkName = networkName
        self.deviceType = deviceType
        self.deviceName = deviceName

        self.setupMesh = setupMesh
        self.simActive = simActive
    }

    override func setContent() {
        if (self.setupMesh!) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoCellularStandalone.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoCellularStandalone.Text1,
            simActive ? Gen3SetupStrings.GatewayInfoCellularStandalone.Text2 : Gen3SetupStrings.GatewayInfoCellularStandalone.Text2Activate
        ]

        continueButton.setTitle(simActive ? Gen3SetupStrings.GatewayInfoCellularStandalone.Button : Gen3SetupStrings.GatewayInfoCellularStandalone.ButtonActivate, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoCellularMesh.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoCellularMesh.Text1,
            simActive ? Gen3SetupStrings.GatewayInfoCellularMesh.Text2 : Gen3SetupStrings.GatewayInfoCellularMesh.Text2Activate,
            Gen3SetupStrings.GatewayInfoCellularMesh.Text3
        ]

        continueButton.setTitle(simActive ? Gen3SetupStrings.GatewayInfoCellularMesh.Button : Gen3SetupStrings.GatewayInfoCellularMesh.ButtonActivate, for: .normal)
    }
}




class Gen3SetupInfoEthernetViewController: Gen3SetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "Gen3SetupInfoView"
    }

    override func setContent() {
        if (self.setupMesh!) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoEthernetStandalone.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoEthernetStandalone.Text1,
            Gen3SetupStrings.GatewayInfoEthernetStandalone.Text2
        ]

        continueButton.setTitle(Gen3SetupStrings.GatewayInfoEthernetStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoEthernetMesh.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoEthernetMesh.Text1,
            Gen3SetupStrings.GatewayInfoEthernetMesh.Text2,
            Gen3SetupStrings.GatewayInfoEthernetMesh.Text3
        ]

        continueButton.setTitle(Gen3SetupStrings.GatewayInfoEthernetMesh.Button, for: .normal)
    }
}






class Gen3SetupInfoWifiViewController: Gen3SetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "Gen3SetupInfoView"
    }

    override func setContent() {
        if (self.setupMesh!) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoWifiStandalone.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoWifiStandalone.Text1,
            Gen3SetupStrings.GatewayInfoWifiStandalone.Text2
        ]

        continueButton.setTitle(Gen3SetupStrings.GatewayInfoWifiStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = Gen3SetupStrings.GatewayInfoWifiMesh.Title

        self.textLabelValues = [
            Gen3SetupStrings.GatewayInfoWifiMesh.Text1,
            Gen3SetupStrings.GatewayInfoWifiMesh.Text2,
            Gen3SetupStrings.GatewayInfoWifiMesh.Text3
        ]

        continueButton.setTitle(Gen3SetupStrings.GatewayInfoWifiMesh.Button, for: .normal)
    }
}
