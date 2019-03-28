//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelWifiViewController : MeshSetupControlPanelRootViewController {

    override var customTitle: String {
        return "Control Panel"
    }

    override func prepareContent() {
        cells = [[.actionNewWifi, .actionManageWifi]]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib.init(nibName: "MeshSetupBasicCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicCell")
        tableView.register(UINib.init(nibName: "MeshSetupBasicIconCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicIconCell")
        tableView.register(UINib.init(nibName: "MeshSetupButtonCell", bundle: nil), forCellReuseIdentifier: "MeshSetupButtonCell")
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}