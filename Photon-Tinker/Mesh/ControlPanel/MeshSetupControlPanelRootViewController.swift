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

    func getCellTitle() -> String {
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
            case .actionActivateSim:
                return "Inactive"
            case .actionDeactivateSim:
                return "Active"
            case .actionActivateEthernet:
                return "Inactive"
            case .actionDeactivateEthernet:
                return "Active"
            case .actionChangeDataLimit:
                return "\(context.targetDevice.sim!.mbLimit!) MB"
            case .actionMeshNetworkInfo:
                return context.targetDevice.meshNetworkInfo!.name
            default:
                return nil
        }
    }

    func getIcon() -> UIImage? {
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
}

class MeshSetupControlPanelRootViewController : MeshSetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    static var nibName: String {
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
    @IBOutlet var additionalViewsToFade: [UIView]?

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
        let image = cellType.getIcon()
        let detail = cellType.getCellDetails(context: self.context)

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
        } else if detail != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupHorizontalDetailCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
            cell.cellDetailLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.SecondaryTextColor)
            cell.cellDetailLabel.text = detail

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

        ParticleSpinner.show(view)
        fadeContent()

        self.callback(cells[indexPath.section][indexPath.row])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (isBusy) {
            ParticleSpinner.hide(view, animated: false)
            ParticleSpinner.show(view)
        }
    }

    internal func fadeContent() {
        self.isBusy = true
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.tableView.alpha = 0.5

            if let additionalViewsToFade = self.additionalViewsToFade {
                for childView in additionalViewsToFade {
                    childView.alpha = 0.5
                }
            }
        }
    }

    internal func unfadeContent(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.tableView.alpha = 1

                if let additionalViewsToFade = self.additionalViewsToFade {
                    for childView in additionalViewsToFade {
                        childView.alpha = 1
                    }
                }
            }
        } else {
            self.tableView.alpha = 1

            if let additionalViewsToFade = self.additionalViewsToFade {
                for childView in additionalViewsToFade {
                    childView.alpha = 1
                }
            }

            self.view.setNeedsDisplay()
        }
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        ParticleSpinner.hide(view, animated: animated)
        unfadeContent(animated: true)
        isBusy = false
    }
}
