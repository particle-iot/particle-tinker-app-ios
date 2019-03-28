//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

enum MeshSetupControlPanelCellType {
    case wifi
    case cellular
    case ethernet
    case mesh
    case documentation
    case unclaim

    case actionNewWifi
    case actionManageWifi
    case actionActivateSim
    case actionDeactivateSim

    func getCellTitle() -> String {
        switch self {
            case .wifi:
                return "Wi-Fi"
            case .cellular:
                return "Cellular"
            case .ethernet:
                return "Ethernet"
            case .mesh:
                return "Mesh"
            case .documentation:
                return "Documentation"
            case .unclaim:
                return "Unclaim Device"

            case .actionNewWifi:
                return "Connect to new Wi-Fi network"
            case .actionManageWifi:
                return "Manage Wi-Fi networks"
            case .actionActivateSim:
                return "Activate SIM card"
            case .actionDeactivateSim:
                return "Deactivate SIM card"
        }
    }

    func getIcon() -> UIImage? {
        switch self {
            case .wifi:
                return UIImage(named: "MeshWifiIcon")
            case .cellular:
                return UIImage(named: "MeshLTEIcon")
            case .ethernet:
                return nil
            case .mesh:
                return UIImage(named: "MeshIcon")
            default:
                return nil
        }
    }
}

class MeshSetupControlPanelRootViewController : MeshSetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    internal var callback: ((MeshSetupControlPanelCellType) -> ())!

    internal var device: ParticleDevice!
    internal var cells: [[MeshSetupControlPanelCellType]]!


    override var customTitle: String {
        return "Control Panel"
    }

    override func setStyle() {
        //do nothing
    }

    override func setContent() {
        //do nothing
    }

    func setup(device: ParticleDevice, didSelectAction: @escaping (MeshSetupControlPanelCellType) -> ()) {
        self.callback = didSelectAction

        self.allowBack = false
        self.device = device

        self.prepareContent()
    }


    internal func prepareContent() {
        cells = []

        switch device.type {
            case .xenon, .xSeries:
                cells.append([.mesh, .ethernet])
            case .boron, .bSeries:
                cells.append([.mesh, .ethernet, .cellular])
            case .argon, .aSeries:
                cells.append([.mesh, .ethernet, .wifi])
            default:
                break
        }

        cells.append([.documentation])
        cells.append([.unclaim])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib.init(nibName: "MeshSetupBasicCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicCell")
        tableView.register(UINib.init(nibName: "MeshSetupBasicIconCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicIconCell")
        tableView.register(UINib.init(nibName: "MeshSetupButtonCell", bundle: nil), forCellReuseIdentifier: "MeshSetupButtonCell")
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == self.numberOfSections(in: tableView) - 1) {
            return 60
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.section][indexPath.row]
        let image = cellType.getIcon()

        var cell:MeshCell! = nil

        if (cellType == .unclaim) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupButtonCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.RedTextColor)

            cell.accessoryView = nil
            cell.accessoryType = .none
        } else if image != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicIconCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }

        cell.cellTitleLabel.text = cellType.getCellTitle()
        cell.cellIconImageView?.image = image

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = MeshSetupStyle.CellHighlightColor
        cell.selectedBackgroundView = cellHighlight

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.callback(cells[indexPath.section][indexPath.row])
    }
}
