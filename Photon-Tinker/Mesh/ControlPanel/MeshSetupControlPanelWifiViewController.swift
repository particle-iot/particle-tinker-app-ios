//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelWifiViewController : MeshSetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    internal var callback: (() -> ())!

    private var device: ParticleDevice!
    override var customTitle: String {
        return "Wi-fi"
    }

    func setup(device: ParticleDevice, didSelectTo: @escaping () -> ()) {
        self.callback = didSelectTo

        self.device = device
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib.init(nibName: "MeshSetupCreateNetworkCell", bundle: nil), forCellReuseIdentifier: "MeshSetupCreateNetworkCell")
    }

    override func setStyle() {

    }

    override func setContent() {

    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = tableView.dequeueReusableCell(withIdentifier: "MeshSetupCreateNetworkCell") as! MeshCell

        cell.cellTitleLabel.text = "Join New Network"
        cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

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

        self.callback()
    }
}
