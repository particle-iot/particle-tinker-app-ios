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
        if (self.context.targetDevice.wifiNetworkInfo != nil) {
            cells = [[.wifiInfoSSID, .wifiInfoChannel, .wifiInfoRSSI], [.actionNewWifi, .actionManageWifi]]
        } else {
            cells = [[.wifiInfoSSID], [.actionNewWifi, .actionManageWifi]]
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return MeshSetupStrings.ControlPanel.Wifi.NetworkInfo
            default:
                return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }



}