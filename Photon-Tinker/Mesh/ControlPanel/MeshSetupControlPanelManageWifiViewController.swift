//
// Created by Raimundas Sakalauskas on 7/23/19.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupControlPanelManageWifiViewController: MeshSetupNetworkListViewController {

    override class var nibName: String {
        return "MeshSetupNetworkListNoActivityIndicatorView"
    }

    internal var networks:[MeshSetupKnownWifiNetworkInfo]?
    internal var callback: ((MeshSetupKnownWifiNetworkInfo) -> ())!

    func setup(didSelectNetwork: @escaping (MeshSetupKnownWifiNetworkInfo) -> ()) {
        self.callback = didSelectNetwork
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewsToFade = [self.networksTableView, self.titleLabel]
    }

    override func setStyle() {
        super.setStyle()
    }

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.ManageWifi.Title
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.ManageWifi.Text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.stopScanning()
    }

    func setNetworks(networks: [MeshSetupKnownWifiNetworkInfo]) {
        var networks = networks
        networks.sort { info, info2 in
            return info.ssid.localizedCaseInsensitiveCompare(info2.ssid) == .orderedAscending
        }
        self.networks = networks
    }


    override func resume(animated: Bool) {
        super.resume(animated: true)

        self.networks = []
        self.networksTableView.reloadData()
        self.networksTableView.isUserInteractionEnabled = true
        self.isBusy = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = nil
        let network = networks![indexPath.row]

        cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupWifiNetworkCell") as! MeshCell

        cell.cellTitleLabel.text = network.ssid
        cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        NSLog("networks![indexPath.row].security = \(networks![indexPath.row].security)")
        if networks![indexPath.row].security == .noSecurity {
            cell.cellSecondaryAccessoryImageView.image = nil
        } else {
            cell.cellSecondaryAccessoryImageView.image = UIImage.init(named: "MeshSetupWifiProtectedIcon")
        }

        cell.cellAccessoryImageView.isHidden = true
        cell.cellSecondaryAccessoryImageView.isHidden = (cell.cellSecondaryAccessoryImageView.image == nil)

        cell.accessoryView = nil
        cell.accessoryType = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isBusy = true
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false

        self.fade(animated: true)
        callback(networks![indexPath.row])
    }
}
