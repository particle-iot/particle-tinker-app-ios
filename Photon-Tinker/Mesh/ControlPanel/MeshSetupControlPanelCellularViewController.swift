//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelCellularViewController : MeshSetupControlPanelRootViewController {
    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }
    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Cellular.Title
    }

    override func prepareContent() {
        cells = [[.actionChangeDataLimit], [.actionChangeSimStatus]]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.prepareContent()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return MeshSetupStrings.ControlPanel.Cellular.CellularDataTitle
            default:
                return ""
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
            case 1:
                switch (context.targetDevice.sim!.status!) {
                    case .activate:
                       return MeshSetupStrings.ControlPanel.Cellular.SimActiveDescription
                    case .inactiveDataLimitReached:
                        return MeshSetupStrings.ControlPanel.Cellular.SimPausedDescription
                    default:
                        return MeshSetupStrings.ControlPanel.Cellular.SimDeactivatedDescription
                }
            default:
                return ""
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cells[indexPath.section][indexPath.row]

        if (cellType == .actionChangeSimStatus) {
            return 60.0
        }

        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let cellType = cells[indexPath.section][indexPath.row]

        if (cellType == .actionChangeSimStatus) {
            let uiView = UIView()
            uiView.tag = indexPath.section

            let uiSwitch = UISwitch()
            uiView.addSubview(uiSwitch)
            uiSwitch.setOn(context.targetDevice.sim!.status! == .activate, animated: false)

            let uiButton = UIButton()
            uiButton.tag = indexPath.row
            uiView.addSubview(uiButton)
            uiButton.addTarget(self, action: #selector(simStatusChanged), for: UIControl.Event.touchUpInside)

            uiButton.frame = uiSwitch.frame
            uiView.frame = uiSwitch.frame

            cell.accessoryView = uiView
        }

        return cell
    }

    @objc func simStatusChanged(sender: UIButton) {
        self.fade()

        self.callback(cells[sender.superview!.tag][sender.tag])
    }
}