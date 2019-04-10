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
            cells = [[.actionMeshNetworkInfo]]
        } else {
            cells = [[.actionMeshNetworkInfo]]
        }

        //cells = [[.actionJoinNetwork, .actionLeaveNetwork, .actionCreateNetwork, .actionPromoteToGateway, .actionDemoteFromGateway]]
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}