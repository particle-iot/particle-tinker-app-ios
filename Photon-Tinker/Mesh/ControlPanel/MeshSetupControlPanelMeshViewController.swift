//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelMeshViewController : MeshSetupControlPanelRootViewController {
    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }
    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Mesh.Title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.prepareContent()
        self.tableView.reloadData()
    }

    override func prepareContent() {
        if (self.context.targetDevice.meshNetworkInfo != nil) {
            cells = [[.meshInfoNetworkName, .meshInfoNetworkID, .meshInfoNetworkExtPanID, .meshInfoNetworkPanID, .meshInfoNetworkChannel, .meshInfoNetworkDeviceCount], [.meshInfoDeviceRole], [.actionLeaveMeshNetwork]]
        } else {
            cells = [[.meshInfoNetworkName], [.actionAddToMeshNetwork]]
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkInfo
            case 1:
                if (self.context.targetDevice.meshNetworkInfo != nil) {
                    return MeshSetupStrings.ControlPanel.Mesh.DeviceInfo
                } else {
                    return ""
                }
            default:
                return ""
        }

    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}