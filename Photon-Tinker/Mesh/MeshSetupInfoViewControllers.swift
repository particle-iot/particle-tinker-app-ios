//
// Created by Raimundas Sakalauskas on 17/10/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation




class MeshSetupInfoJoinerViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
    }

    override func setContent() {
        titleLabel.text = MeshStrings.JoinerInfo.Title

        self.textLabelValues = [
            MeshStrings.JoinerInfo.Text1,
            MeshStrings.JoinerInfo.Text2,
            MeshStrings.JoinerInfo.Text3
        ]

        continueButton.setTitle(MeshStrings.JoinerInfo.Button, for: .normal)

        setLabelValues()
    }
}



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
        if (self.setupMesh!) {
            showGatewayMeshContent()
        } else {
            showGatewayStandAloneContent()
        }

        setLabelValues()
    }

    private func showGatewayStandAloneContent() {
        titleLabel.text = MeshStrings.GatewayInfoCellularStandalone.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoCellularStandalone.Text1,
            simActive ? MeshStrings.GatewayInfoCellularStandalone.Text2 : MeshStrings.GatewayInfoCellularStandalone.Text2Activate
        ]

        continueButton.setTitle(simActive ? MeshStrings.GatewayInfoCellularStandalone.Button : MeshStrings.GatewayInfoCellularStandalone.ButtonActivate, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshStrings.GatewayInfoCellularMesh.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoCellularMesh.Text1,
            simActive ? MeshStrings.GatewayInfoCellularMesh.Text2 : MeshStrings.GatewayInfoCellularMesh.Text2Activate,
            MeshStrings.GatewayInfoCellularMesh.Text3
        ]

        continueButton.setTitle(simActive ? MeshStrings.GatewayInfoCellularMesh.Button : MeshStrings.GatewayInfoCellularMesh.ButtonActivate, for: .normal)
    }
}




class MeshSetupInfoEthernetViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
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
        titleLabel.text = MeshStrings.GatewayInfoEthernetStandalone.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoEthernetStandalone.Text1,
            MeshStrings.GatewayInfoEthernetStandalone.Text2
        ]

        continueButton.setTitle(MeshStrings.GatewayInfoEthernetStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshStrings.GatewayInfoEthernetMesh.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoEthernetMesh.Text1,
            MeshStrings.GatewayInfoEthernetMesh.Text2,
            MeshStrings.GatewayInfoEthernetMesh.Text3
        ]

        continueButton.setTitle(MeshStrings.GatewayInfoEthernetMesh.Button, for: .normal)
    }
}






class MeshSetupInfoWifiViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
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
        titleLabel.text = MeshStrings.GatewayInfoWifiStandalone.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoWifiStandalone.Text1,
            MeshStrings.GatewayInfoWifiStandalone.Text2
        ]

        continueButton.setTitle(MeshStrings.GatewayInfoWifiStandalone.Button, for: .normal)
    }

    private func showGatewayMeshContent() {
        titleLabel.text = MeshStrings.GatewayInfoWifiMesh.Title

        self.textLabelValues = [
            MeshStrings.GatewayInfoWifiMesh.Text1,
            MeshStrings.GatewayInfoWifiMesh.Text2,
            MeshStrings.GatewayInfoWifiMesh.Text3
        ]

        continueButton.setTitle(MeshStrings.GatewayInfoWifiMesh.Button, for: .normal)
    }
}
