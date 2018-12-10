//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectWifiNetworkViewController: MeshSetupNetworkListViewController {

    private var networks:[MeshSetupNewWifiNetworkInfo]?
    private var callback: ((MeshSetupNewWifiNetworkInfo) -> ())!

    func setup(didSelectNetwork: @escaping (MeshSetupNewWifiNetworkInfo) -> ()) {
        self.callback = didSelectNetwork
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.SelectWifiNetwork.Title
    }

    func setNetworks(networks: [MeshSetupNewWifiNetworkInfo]) {
        var networks = networks

        for i in (0 ..< networks.count).reversed() {
            if networks[i].ssid.count == 0 {
                networks.remove(at: i)
            }
        }

        networks.sort { info, info2 in
            return info.ssid < info2.ssid
        }
        self.networks = networks

        self.stopScanning()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupWifiNetworkCell") as! MeshCell

        cell.cellTitleLabel.text = networks![indexPath.row].ssid
        cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)


        if (networks![indexPath.row].rssi > -56) {
            cell.cellAccessoryImageView.image = UIImage.init(named: "MeshSetupWifiStrongIcon")
        } else if (networks![indexPath.row].rssi > -71) {
            cell.cellAccessoryImageView.image = UIImage.init(named: "MeshSetupWifiMediumIcon")
        } else {
            cell.cellAccessoryImageView.image = UIImage.init(named: "MeshSetupWifiWeakIcon")
        }

        if networks![indexPath.row].security == .noSecurity {
            cell.cellSecondaryAccessoryImageView.image = nil
        } else {
            cell.cellSecondaryAccessoryImageView.image = UIImage.init(named: "MeshSetupWifiProtectedIcon")
        }
        cell.cellSecondaryAccessoryImageView.isHidden = (cell.cellSecondaryAccessoryImageView.image == nil)

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
