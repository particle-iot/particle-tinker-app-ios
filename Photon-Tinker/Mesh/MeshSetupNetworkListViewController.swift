//
// Created by Raimundas Sakalauskas on 09/10/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupNetworkListViewController: Gen3SetupViewController, Storyboardable, UITableViewDelegate, UITableViewDataSource {

    class var nibName: String {
        return "Gen3SetupNetworkListView"
    }

    @IBOutlet weak var networksTableView: UITableView!

    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var scanActivityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        networksTableView.delegate = self
        networksTableView.dataSource = self

        networksTableView.register(UINib.init(nibName: "Gen3SetupSubtitleCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupSubtitleCell")
        networksTableView.register(UINib.init(nibName: "Gen3SetupBasicCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupBasicCell")
        networksTableView.register(UINib.init(nibName: "Gen3SetupWifiNetworkCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupWifiNetworkCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startScanning()
    }

    override func setStyle() {
        networksTableView.tableFooterView = UIView()

        scanActivityIndicator?.color = ParticleStyle.NetworkScanActivityIndicatorColor
        scanActivityIndicator?.hidesWhenStopped = true

        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
    }

    func startScanning() {
        DispatchQueue.main.async {
            self.scanActivityIndicator?.startAnimating()
        }
    }

    func stopScanning() {
        DispatchQueue.main.async {
            //self.scanActivityIndicator?.stopAnimating()
            self.networksTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("tableView(tableView:indexPath:) has not been implemented")
    }
}
