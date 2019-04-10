//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelWifiViewController : MeshSetupControlPanelRootViewController {
    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }
    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Wifi.Title
    }

    override func prepareContent() {
        cells = [[.actionNewWifi]]//, .actionManageWifi]]
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}