//
// Created by Raimundas Sakalauskas on 17/10/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshSetupGatewayInfoArgonViewController: MeshSetupInfoViewController, Storyboardable {
    static var nibName: String {
        return "MeshSetupInfoView"
    }

    override func setContent() {
        if (self.setupMesh) {
            titleLabel.text = MeshSetupStrings.GatewayInfoArgonMesh.Title

            self.textLabelValues = [
                MeshSetupStrings.GatewayInfoArgonMesh.Text1,
                MeshSetupStrings.GatewayInfoArgonMesh.Text2,
                MeshSetupStrings.GatewayInfoArgonMesh.Text3
            ]

            continueButton.setTitle(MeshSetupStrings.GatewayInfoArgonMesh.Button, for: .normal)
        } else {
            titleLabel.text = MeshSetupStrings.GatewayInfoArgonStandalone.Title

            self.textLabelValues = [
                MeshSetupStrings.GatewayInfoArgonStandalone.Text1,
                MeshSetupStrings.GatewayInfoArgonStandalone.Text2
            ]

            continueButton.setTitle(MeshSetupStrings.GatewayInfoArgonStandalone.Button, for: .normal)
        }

        setProgressLabelValues()
    }
}
