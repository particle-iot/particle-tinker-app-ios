//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupSelectDeviceViewController: MeshSetupViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var deviceTypeTableView: UITableView!

    private let deviceTypes = [ ParticleDeviceType.xenon.description, ParticleDeviceType.argon.description, ParticleDeviceType.boron.description ]
    private let deviceDescriptionTypes = [MeshSetupStrings.SelectDevice.MeshOnly, MeshSetupStrings.SelectDevice.MeshAndWifi, MeshSetupStrings.SelectDevice.MeshAndCellular ]
    private let secondaryAccessoryImages = [nil, "MeshWifiIcon", "MeshLTEIcon"]
    private var enabledCells: [Bool]!

    private var callback: ((ParticleDeviceType) -> ())!

    func setup(didSelectDevice: @escaping (ParticleDeviceType) -> ()) {
        self.callback = didSelectDevice
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        deviceTypeTableView.delegate = self
        deviceTypeTableView.dataSource = self
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        //remove extra cells at the bottom
        deviceTypeTableView.tableFooterView = UIView()
        deviceTypeTableView.backgroundColor = MeshSetupStyle.ViewBackgroundColor
        deviceTypeTableView.separatorColor = MeshSetupStyle.CellSeparatorColor

        enabledCells = [
            LDClient.sharedInstance().boolVariation("temp-xenon-in-ios", fallback: false),
            LDClient.sharedInstance().boolVariation("temp-argon-in-ios", fallback: false),
            LDClient.sharedInstance().boolVariation("temp-boron-in-ios", fallback: false)
        ]
    }

    override func setContent() {
        enabledCells = [
            LDClient.sharedInstance().boolVariation("temp-xenon-in-ios", fallback: false),
            LDClient.sharedInstance().boolVariation("temp-argon-in-ios", fallback: false),
            LDClient.sharedInstance().boolVariation("temp-boron-in-ios", fallback: false)
        ]

        titleLabel.text = MeshSetupStrings.SelectDevice.Title
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceTypes.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meshDeviceCell") as! MeshDeviceCell

        var enabled = enabledCells[indexPath.row]

        cell.cellTitleLabel.text = deviceTypes[indexPath.row]
        cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.ExtraLargeSize, color: enabled ? MeshSetupStyle.PrimaryTextColor : MeshSetupStyle.DisabledTextColor)

        cell.cellSubtitleLabel.text = deviceDescriptionTypes[indexPath.row]
        cell.cellSubtitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: enabled ? MeshSetupStyle.PrimaryTextColor : MeshSetupStyle.DisabledTextColor)

        cell.cellImageView.image = UIImage.init(named: "imgDevice" + deviceTypes[indexPath.row])
        cell.cellAccessoryImageView.alpha = enabled ? 1 : 0.5

        if let icon = secondaryAccessoryImages[indexPath.row] {
            cell.cellSecondaryAccessoryImageView.image = UIImage.init(named: icon)
            cell.cellSecondaryAccessoryImageView.alpha = enabled ? 1 : 0.5
        } else {
            cell.cellSecondaryAccessoryImageView.image = nil
        }
        cell.cellSecondaryAccessoryImageView.isHidden = (cell.cellSecondaryAccessoryImageView.image == nil)

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = MeshSetupStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return enabledCells[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
            case 0:
                callback(ParticleDeviceType.xenon)
            case 1:
                callback(ParticleDeviceType.argon)
            case 2:
                callback(ParticleDeviceType.boron)
            default:
                callback(ParticleDeviceType.xenon)
        }
    }
}

