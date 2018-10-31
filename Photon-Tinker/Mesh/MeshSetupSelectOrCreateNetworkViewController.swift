//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectOrCreateNetworkViewController: MeshSetupNetworkListViewController {

    private var networks:[MeshSetupNetworkInfo]?
    private var callback: ((MeshSetupNetworkInfo?) -> ())!

    func setup(didSelectGatewayNetwork: @escaping (MeshSetupNetworkInfo?) -> ()) {
        self.callback = didSelectGatewayNetwork
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.CreateOrSelectNetwork.Title
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
        return (networks?.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MeshDeviceCell!
        if (indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupCreateNetworkCell") as! MeshDeviceCell

            cell.cellTitleLabel.text = MeshSetupStrings.CreateOrSelectNetwork.CreateNetwork
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupMeshNetworkCell") as! MeshDeviceCell

            cell.cellTitleLabel.text = networks![indexPath.row-1].name
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            //TODO: remove this hardcoded string
            cell.cellSubtitleLabel.text = "? devices on network"
            cell.cellSubtitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
        }

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


        if (indexPath.row == 0) {
            callback(nil)
        } else {
            callback(networks![indexPath.row-1])
        }
    }
}
