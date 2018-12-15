//
// Created by Raimundas Sakalauskas on 17/10/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation



class MeshSetupCellularInfoViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
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
        if (self.setupMesh) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoCellularStandalone.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoCellularStandalone.Text1,
            simActive ? MeshSetupStrings.GatewayInfoCellularStandalone.Text2 : MeshSetupStrings.GatewayInfoCellularStandalone.Text2Activate
        ]

        continueButton.setTitle(simActive ? MeshSetupStrings.GatewayInfoCellularStandalone.Button : MeshSetupStrings.GatewayInfoCellularStandalone.ButtonActivate, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoCellularMesh.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoCellularMesh.Text1,
            simActive ? MeshSetupStrings.GatewayInfoCellularMesh.Text2 : MeshSetupStrings.GatewayInfoCellularMesh.Text2Activate,
            MeshSetupStrings.GatewayInfoCellularMesh.Text3
        ]

        continueButton.setTitle(simActive ? MeshSetupStrings.GatewayInfoCellularMesh.Button : MeshSetupStrings.GatewayInfoCellularMesh.ButtonActivate, for: .normal)
    }
}



class MeshSetupInfoJoinerViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
    }

    override var allowBack: Bool {
        return false
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.JoinerInfo.Title

        self.textLabelValues = [
            MeshSetupStrings.JoinerInfo.Text1,
            MeshSetupStrings.JoinerInfo.Text2,
            MeshSetupStrings.JoinerInfo.Text3
        ]

        continueButton.setTitle(MeshSetupStrings.JoinerInfo.Button, for: .normal)

        setLabelValues()
    }
}


class MeshSetupInfoEthernetViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
    }

    override func setContent() {
        if (self.setupMesh) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoEthernetStandalone.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoEthernetStandalone.Text1,
            MeshSetupStrings.GatewayInfoEthernetStandalone.Text2
        ]

        continueButton.setTitle(MeshSetupStrings.GatewayInfoEthernetStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoEthernetMesh.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoEthernetMesh.Text1,
            MeshSetupStrings.GatewayInfoEthernetMesh.Text2,
            MeshSetupStrings.GatewayInfoEthernetMesh.Text3
        ]

        continueButton.setTitle(MeshSetupStrings.GatewayInfoEthernetMesh.Button, for: .normal)
    }
}






class MeshSetupInfoWifiViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
    }

    override func setContent() {
        if (self.setupMesh) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoWifiStandalone.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoWifiStandalone.Text1,
            MeshSetupStrings.GatewayInfoWifiStandalone.Text2
        ]

        continueButton.setTitle(MeshSetupStrings.GatewayInfoWifiStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshSetupStrings.GatewayInfoWifiMesh.Title

        self.textLabelValues = [
            MeshSetupStrings.GatewayInfoWifiMesh.Text1,
            MeshSetupStrings.GatewayInfoWifiMesh.Text2,
            MeshSetupStrings.GatewayInfoWifiMesh.Text3
        ]

        continueButton.setTitle(MeshSetupStrings.GatewayInfoWifiMesh.Button, for: .normal)
    }
}
