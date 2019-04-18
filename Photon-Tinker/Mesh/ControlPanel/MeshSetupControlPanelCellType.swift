//
// Created by Raimundas Sakalauskas on 2019-04-17.
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

    case actionChangeSimStatus
    case actionChangeDataLimit

    case actionChangePinsStatus

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

            case .actionChangeSimStatus:
                return MeshSetupStrings.ControlPanel.Cellular.ChangeSimStatus
            case .actionChangeDataLimit:
                return MeshSetupStrings.ControlPanel.Cellular.ChangeDataLimit

            case .actionChangePinsStatus:
                return MeshSetupStrings.ControlPanel.Ethernet.ChangePinsStatus

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
            case .actionChangeSimStatus:
                if context.targetDevice.sim!.status! == .activate {
                    return MeshSetupStrings.ControlPanel.Cellular.Active
                } else if (context.targetDevice.sim!.status! == .inactiveDataLimitReached) {
                    return MeshSetupStrings.ControlPanel.Cellular.Paused
                } else {
                    return MeshSetupStrings.ControlPanel.Cellular.Inactive
                }
            case .actionChangePinsStatus:
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
            case .actionChangeSimStatus:
                return false
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
            case .actionChangeSimStatus:
                return .none
            default:
                return .disclosureIndicator
        }
    }
}
