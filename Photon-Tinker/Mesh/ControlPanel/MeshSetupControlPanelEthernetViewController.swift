//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class MeshSetupControlPanelEthernetViewController : MeshSetupControlPanelRootViewController {
    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }
    override var customTitle: String {
        return MeshStrings.ControlPanel.Ethernet.Title
    }

    override func prepareContent() {
        if (context.targetDevice.ethernetDetectionFeature!) {
            cells = [[.actionChangePinsStatus]]
        } else {
            cells = [[.actionChangePinsStatus]]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.prepareContent()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return MeshStrings.ControlPanel.Ethernet.Footer
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cells[indexPath.section][indexPath.row]

        if (cellType == .actionChangePinsStatus) {
            return 60.0
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let cellType = cells[indexPath.section][indexPath.row]

        if (cellType == .actionChangePinsStatus) {
            let uiView = UIView()
            uiView.tag = indexPath.section

            let uiSwitch = UISwitch()
            uiView.addSubview(uiSwitch)
            uiSwitch.setOn(context.targetDevice.ethernetDetectionFeature!, animated: false)

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
