//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelWifiViewController : MeshSetupControlPanelRootViewController {

    private let refreshControl = UIRefreshControl()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        refreshControl.tintColor = ParticleStyle.SecondaryTextColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }

    @objc private func refreshData(_ sender: Any) {
        self.fadeContent(animated: true, showSpinner: false)
        self.callback(.wifi)
    }

    override func resume(animated: Bool) {
        self.prepareContent()

        super.resume(animated: animated)

        self.tableView.refreshControl?.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.prepareContent()
        self.tableView.reloadData()
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
        return UITableView.automaticDimension
    }



}
