//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectNetworkViewController: MeshSetupNetworkListViewController {

    internal var networks:[MeshSetupNetworkCellInfo]?
    internal var callback: ((MeshSetupNetworkCellInfo?) -> ())!

    func setup(didSelectNetwork: @escaping (MeshSetupNetworkCellInfo?) -> ()) {
        self.callback = didSelectNetwork
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.SelectNetwork.Title
    }

    func setNetworks(networks: [MeshSetupNetworkCellInfo]) {
        var networks = networks
        networks.sort { info, info2 in
            return info.name.localizedCaseInsensitiveCompare(info2.name) == .orderedAscending
        }
        self.networks = networks

        self.stopScanning()
    }


    override func resume(animated: Bool) {
        super.resume(animated: true)

        self.networks = []
        self.networksTableView.reloadData()
        self.startScanning()
        self.networksTableView.isUserInteractionEnabled = true
        self.isBusy = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = nil
        let network = networks![indexPath.row]
        if (network.userOwned) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupSubtitleCell") as! MeshCell

            var devicesString = (network.deviceCount! == 1) ? MeshSetupStrings.SelectNetwork.DevicesSingular : MeshSetupStrings.SelectNetwork.DevicesPlural
            devicesString = devicesString.replacingOccurrences(of: "{{0}}", with: String(network.deviceCount!))

            cell.cellSubtitleLabel.text = devicesString
            cell.cellSubtitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell
        }

        cell.cellTitleLabel.text = network.name
        cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isBusy = true
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false

        if let cell = tableView.cellForRow(at: indexPath) {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.color = ParticleStyle.NetworkJoinActivityIndicatorColor
            activityIndicator.startAnimating()

            cell.accessoryView = activityIndicator
        }

        scanActivityIndicator.stopAnimating()
        callback(networks![indexPath.row])
    }
}
