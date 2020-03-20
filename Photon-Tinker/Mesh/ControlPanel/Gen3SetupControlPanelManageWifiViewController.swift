//
// Created by Raimundas Sakalauskas on 7/23/19.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupControlPanelManageWifiViewController: Gen3SetupNetworkListViewController {

    override class var nibName: String {
        return "Gen3SetupNetworkListNoActivityIndicatorView"
    }

    internal var networks:[Gen3SetupKnownWifiNetworkInfo]?
    internal var callback: ((Gen3SetupKnownWifiNetworkInfo) -> ())!

    func setup(didSelectNetwork: @escaping (Gen3SetupKnownWifiNetworkInfo) -> ()) {
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
        return Gen3SetupStrings.ControlPanel.ManageWifi.Title
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.ControlPanel.ManageWifi.Text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.stopScanning()
    }

    func setNetworks(networks: [Gen3SetupKnownWifiNetworkInfo]) {
        var networks = networks
        networks.sort { info, info2 in
            return info.ssid.localizedCaseInsensitiveCompare(info2.ssid) == .orderedAscending
        }
        self.networks = networks
    }


    override func resume(animated: Bool) {
        super.resume(animated: true)
        
        self.networksTableView.reloadData()
        self.networksTableView.isUserInteractionEnabled = true
        self.isBusy = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:Gen3Cell! = nil
        let network = networks![indexPath.row]

        cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupWifiNetworkCell") as! Gen3Cell

        cell.cellTitleLabel.text = network.ssid
        cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        NSLog("networks![indexPath.row].security = \(networks![indexPath.row].security)")
        if networks![indexPath.row].credentialsType == .noCredentials {
            cell.cellSecondaryAccessoryImageView.image = nil
        } else {
            cell.cellSecondaryAccessoryImageView.image = UIImage.init(named: "Gen3SetupWifiProtectedIcon")
        }

        cell.cellAccessoryImageView.isHidden = true
        cell.cellSecondaryAccessoryImageView.isHidden = (cell.cellSecondaryAccessoryImageView.image == nil)

        cell.accessoryView = nil
        cell.accessoryType = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let alert = UIAlertController(title: Gen3SetupStrings.ControlPanel.Prompt.DeleteWifiTitle, message: Gen3SetupStrings.ControlPanel.Prompt.DeleteWifiText.replacingOccurrences(of: "{{wifiSSID}}", with: self.networks![indexPath.row].ssid), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Gen3SetupStrings.ControlPanel.Action.DeleteWifi, style: .default) { action in
            tableView.isUserInteractionEnabled = false
            self.isBusy = true

            self.fade(animated: true)
            self.callback(self.networks![indexPath.row])
        })

        alert.addAction(UIAlertAction(title: Gen3SetupStrings.ControlPanel.Action.DontDeleteWifi, style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }
}
