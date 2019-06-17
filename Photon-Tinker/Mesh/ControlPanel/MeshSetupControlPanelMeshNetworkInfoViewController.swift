//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelMeshNetworkInfoViewController : MeshSetupControlPanelRootViewController {

    internal var cellTitles = [
        MeshSetupStrings.ControlPanel.Mesh.NetworkName,
        MeshSetupStrings.ControlPanel.Mesh.NetworkID,
        MeshSetupStrings.ControlPanel.Mesh.NetworkExtPanID,
        MeshSetupStrings.ControlPanel.Mesh.NetworkPanID,
        MeshSetupStrings.ControlPanel.Mesh.NetworkChannel
    ]
    internal var cellDetails: [String]!

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Mesh.NetworkInfo
    }

    func setup(device: ParticleDevice, context: MeshSetupContext!) {
        self.context = context
        self.device = device

        cellDetails = [
            self.context.targetDevice.meshNetworkInfo!.name,
            self.context.targetDevice.meshNetworkInfo!.networkID,
            self.context.targetDevice.meshNetworkInfo!.extPanID,
            String(self.context.targetDevice.meshNetworkInfo!.panID),
            String(self.context.targetDevice.meshNetworkInfo!.channel)
        ]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = tableView.dequeueReusableCell(withIdentifier: "MeshSetupHorizontalDetailCell") as! MeshCell
        cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        cell.cellDetailLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.DetailsTextColor)
        cell.accessoryType = .none

        cell.cellTitleLabel.text = cellTitles[indexPath.row]
        cell.cellDetailLabel.text = cellDetails[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}