//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectNetworkViewController: MeshSetupNetworkListViewController {

    private var networks:[MeshSetupNetworkInfo]?
    private var callback: ((MeshSetupNetworkInfo) -> ())!

    func setup(didSelectNetwork: @escaping (MeshSetupNetworkInfo) -> ()) {
        self.callback = didSelectNetwork
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.SelectNetwork.Title
    }

    func setNetworks(networks: [MeshSetupNetworkInfo]) {
        var networks = networks
        networks.sort { info, info2 in
            return info.name < info2.name
        }
        self.networks = networks

        self.stopScanning()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupMeshNetworkCell") as! MeshDeviceCell

        cell.cellTitleLabel.text = networks![indexPath.row].name
        cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        cell.cellSubtitleLabel.text = "? devices on network"
        cell.cellSubtitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = MeshSetupStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false

        if let cell = tableView.cellForRow(at: indexPath) {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.color = MeshSetupStyle.NetworkJoinActivityIndicatorColor
            activityIndicator.startAnimating()

            cell.accessoryView = activityIndicator
        }

        scanActivityIndicator.stopAnimating()
        callback(networks![indexPath.row])
    }
}
