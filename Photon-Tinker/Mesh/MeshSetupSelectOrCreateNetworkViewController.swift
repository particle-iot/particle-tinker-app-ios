//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectOrCreateNetworkViewController: MeshSetupViewController, Storyboardable, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var networksTableView: UITableView!

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var scanActivityIndicator: UIActivityIndicatorView!

    private var networks:[MeshSetupNetworkInfo]?
    private var callback: ((MeshSetupNetworkInfo?) -> ())!

    override func viewDidLoad() {
        super.viewDidLoad()

        networksTableView.delegate = self
        networksTableView.dataSource = self
    }

    func setup(didSelectGatewayNetwork: @escaping (MeshSetupNetworkInfo?) -> ()) {
        self.callback = didSelectGatewayNetwork
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startScanning()
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.Networks.Title
    }

    override func setStyle() {
        networksTableView.tableFooterView = UIView()

        scanActivityIndicator.color = MeshSetupStyle.NetworkScanActivityIndicatorColor
        scanActivityIndicator.hidesWhenStopped = true

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    func startScanning() {
        DispatchQueue.main.async {
            self.scanActivityIndicator.startAnimating()
        }
    }

    func setNetworks(networks: [MeshSetupNetworkInfo]) {
        self.networks = networks

        DispatchQueue.main.async {
            self.scanActivityIndicator.stopAnimating()
            self.networksTableView.reloadData()
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (networks?.count ?? 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MeshDeviceCell!
        if (indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "meshCreateNetworkCell") as! MeshDeviceCell

            cell.cellTitleLabel.text = MeshSetupStrings.CreateOrSelectNetwork.CreateNetwork
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "meshNetworkCell") as! MeshDeviceCell

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

   

    
}