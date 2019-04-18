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
    case actionChangeDataLimit

    case actionActivateEthernet
    case actionDeactivateEthernet

    case actionJoinNetwork
    case actionCreateNetwork
    case actionLeaveNetwork
    case actionPromoteToGateway
    case actionDemoteFromGateway
    case actionMeshNetworkInfo

    func getCellTitle(context: MeshSetupContext) -> String {
        switch self {
            case .wifi:
                return MeshSetupStrings.ControlPanel.Root.Wifi
            case .cellular:
                return MeshSetupStrings.ControlPanel.Root.Cellular
            case .ethernet:
                return MeshSetupStrings.ControlPanel.Root.Ethernet
            case .mesh:
                return MeshSetupStrings.ControlPanel.Root.Mesh
            case .documentation:
                return MeshSetupStrings.ControlPanel.Root.Documentation
            case .unclaim:
                return MeshSetupStrings.ControlPanel.Root.UnclaimDevice

            case .actionNewWifi:
                return MeshSetupStrings.ControlPanel.Wifi.AddNewWifi
            case .actionManageWifi:
                return MeshSetupStrings.ControlPanel.Wifi.ManageWifi

            case .actionActivateSim:
                return MeshSetupStrings.ControlPanel.Cellular.ActivateSim
            case .actionDeactivateSim:
                return MeshSetupStrings.ControlPanel.Cellular.DeactivateSim
            case .actionChangeDataLimit:
                return MeshSetupStrings.ControlPanel.Cellular.ChangeDataLimit


            case .actionActivateEthernet:
                return MeshSetupStrings.ControlPanel.Ethernet.ActivateEthernet
            case .actionDeactivateEthernet:
                return MeshSetupStrings.ControlPanel.Ethernet.DeactivateEthernet

            case .actionJoinNetwork:
                return MeshSetupStrings.ControlPanel.Mesh.JoinNetwork
            case .actionCreateNetwork:
                return MeshSetupStrings.ControlPanel.Mesh.CreateNetwork
            case .actionLeaveNetwork:
                return MeshSetupStrings.ControlPanel.Mesh.LeaveNetwork
            case .actionPromoteToGateway:
                return MeshSetupStrings.ControlPanel.Mesh.PromoteToGateway
            case .actionDemoteFromGateway:
                return MeshSetupStrings.ControlPanel.Mesh.DemoteFromGateway
            case .actionMeshNetworkInfo:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkInfo
        }
    }

    func getCellDetails(context: MeshSetupContext) -> String? {
        switch self {
            case .actionActivateSim, .actionDeactivateSim:
                return context.targetDevice.sim!.active! ? MeshSetupStrings.ControlPanel.Cellular.Active : MeshSetupStrings.ControlPanel.Cellular.Inactive
            case .actionActivateEthernet, .actionDeactivateEthernet:
                return context.targetDevice.ethernetDetectionFeature! ? MeshSetupStrings.ControlPanel.Ethernet.Active : MeshSetupStrings.ControlPanel.Ethernet.Inactive
            case .actionChangeDataLimit:
                return MeshSetupStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{0}}", with: String(context.targetDevice.sim!.dataLimit!))
            case .actionMeshNetworkInfo:
                if let network = context.targetDevice.meshNetworkInfo {
                    return network.name
                } else {
                    return ""
                    //return MeshSetupStrings.ControlPanel.Mesh.NoNetworkInfo
                }
            default:
                return nil
        }
    }

    func getCellEnabled(context: MeshSetupContext) -> Bool {
        switch self {
            case .actionMeshNetworkInfo:
                if let network = context.targetDevice.meshNetworkInfo {
                    return true
                } else {
                    return false
                }
            default:
                return true
        }
    }

    func getIcon(context: MeshSetupContext) -> UIImage? {
        switch self {
            case .wifi:
                return UIImage(named: "MeshSetupWifiIcon")
            case .cellular:
                return UIImage(named: "MeshSetupCellularIcon")
            case .ethernet:
                return UIImage(named: "MeshSetupEthernetIcon")
            case .mesh:
                return UIImage(named: "MeshSetupMeshIcon")
            default:
                return nil
        }
    }

    func getDisclosureIndicator(context: MeshSetupContext) -> UITableViewCell.AccessoryType {
        switch self {
            case .unclaim:
                return .none
            case .actionMeshNetworkInfo:
                if let network = context.targetDevice.meshNetworkInfo {
                    return .disclosureIndicator
                } else {
                    return .none
                }
            default:
                return .disclosureIndicator
        }
    }
}

class MeshSetupControlPanelRootViewController : MeshSetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    class var nibName: String {
        return "MeshSetupControlPanelActionList"
    }

    override var allowBack: Bool {
        get {
            return false
        }
        set {
            super.allowBack = newValue
        }
    }

    @IBOutlet weak var tableView: UITableView!

    internal var callback: ((MeshSetupControlPanelCellType) -> ())!

    internal var device: ParticleDevice!
    internal var cells: [[MeshSetupControlPanelCellType]]!

    internal weak var context: MeshSetupContext!


    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Root.Title
    }

    override func setStyle() {
        //do nothing
    }

    override func setContent() {
        //do nothing
    }

    func setup(device: ParticleDevice, context: MeshSetupContext!, didSelectAction: @escaping (MeshSetupControlPanelCellType) -> ()) {
        self.callback = didSelectAction

        self.context = context
        self.device = device

        self.prepareContent()
    }


    internal func prepareContent() {
        cells = []

        switch device.type {
            case .xenon, .xSeries:
                cells.append([.mesh, .ethernet])
            case .boron, .bSeries:
                cells.append([.cellular, .mesh, .ethernet])
            case .argon, .aSeries:
                cells.append([.wifi, .mesh, .ethernet])
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

        if (viewsToFade == nil) {
            viewsToFade = [self.tableView]
        } else {
            viewsToFade?.append(self.tableView)
        }
        tableView.register(UINib.init(nibName: "MeshSetupBasicCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicCell")
        tableView.register(UINib.init(nibName: "MeshSetupBasicIconCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicIconCell")
        tableView.register(UINib.init(nibName: "MeshSetupButtonCell", bundle: nil), forCellReuseIdentifier: "MeshSetupButtonCell")
        tableView.register(UINib.init(nibName: "MeshSetupHorizontalDetailCell", bundle: nil), forCellReuseIdentifier: "MeshSetupHorizontalDetailCell")
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
        let image = cellType.getIcon(context: self.context)
        let detail = cellType.getCellDetails(context: self.context)
        let enabled = cellType.getCellEnabled(context: self.context)
        let accessoryType = cellType.getDisclosureIndicator(context: self.context)

        var cell:MeshCell! = nil

        if (cellType == .unclaim) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupButtonCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: enabled ? MeshSetupStyle.RedTextColor : MeshSetupStyle.SecondaryTextColor)
        } else if image != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicIconCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: enabled ? MeshSetupStyle.PrimaryTextColor : MeshSetupStyle.SecondaryTextColor)
        } else if detail != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupHorizontalDetailCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: enabled ? MeshSetupStyle.PrimaryTextColor : MeshSetupStyle.SecondaryTextColor)

            cell.cellDetailLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
            cell.cellDetailLabel.text = detail
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: enabled ? MeshSetupStyle.PrimaryTextColor : MeshSetupStyle.SecondaryTextColor)
        }

        cell.tintColor = MeshSetupStyle.SecondaryTextColor
        cell.accessoryType = accessoryType
        cell.cellTitleLabel.text = cellType.getCellTitle(context: self.context)
        cell.cellIconImageView?.image = image

        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellType = cells[indexPath.section][indexPath.row]

        return cellType.getCellEnabled(context: self.context)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.fade()

        self.callback(cells[indexPath.section][indexPath.row])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
