//
// Created by Raimundas Sakalauskas on 2019-04-17.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum Gen3SetupControlPanelCellType {
    case name
    case notes

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

    case actionPromoteToGateway
    case actionDemoteFromGateway


    case meshInfoNetworkName
    case meshInfoNetworkID
    case meshInfoNetworkExtPanID
    case meshInfoNetworkPanID
    case meshInfoNetworkChannel
    case meshInfoNetworkDeviceCount
    case meshInfoDeviceRole


    case wifiInfoSSID
    case wifiInfoChannel
    case wifiInfoRSSI


    case actionLeaveMeshNetwork
    case actionAddToMeshNetwork

    func getCellTitle(context: Gen3SetupContext) -> String {
        switch self {
            case .name:
                return Gen3SetupStrings.ControlPanel.Root.Name
            case .notes:
                return Gen3SetupStrings.ControlPanel.Root.Notes
            case .wifi:
                return Gen3SetupStrings.ControlPanel.Root.Wifi
            case .cellular:
                return Gen3SetupStrings.ControlPanel.Root.Cellular
            case .ethernet:
                return Gen3SetupStrings.ControlPanel.Root.Ethernet
            case .mesh:
                return Gen3SetupStrings.ControlPanel.Root.Mesh
            case .documentation:
                return Gen3SetupStrings.ControlPanel.Root.Documentation
            case .unclaim:
                return Gen3SetupStrings.ControlPanel.Root.UnclaimDevice

            case .actionNewWifi:
                return Gen3SetupStrings.ControlPanel.Wifi.AddNewWifi
            case .actionManageWifi:
                return Gen3SetupStrings.ControlPanel.Wifi.ManageWifi

            case .wifiInfoSSID:
                return Gen3SetupStrings.ControlPanel.Wifi.SSID
            case .wifiInfoChannel:
                return Gen3SetupStrings.ControlPanel.Wifi.Channel
            case .wifiInfoRSSI:
                return Gen3SetupStrings.ControlPanel.Wifi.RSSI


            case .actionChangeSimStatus:
                return Gen3SetupStrings.ControlPanel.Cellular.ChangeSimStatus
            case .actionChangeDataLimit:
                return Gen3SetupStrings.ControlPanel.Cellular.ChangeDataLimit

            case .actionChangePinsStatus:
                return Gen3SetupStrings.ControlPanel.Ethernet.ChangePinsStatus


            case .meshInfoNetworkName:
                return Gen3SetupStrings.ControlPanel.Mesh.NetworkName
            case .meshInfoNetworkID:
                return Gen3SetupStrings.ControlPanel.Mesh.NetworkID
            case .meshInfoNetworkExtPanID:
                return Gen3SetupStrings.ControlPanel.Mesh.NetworkExtPanID
            case .meshInfoNetworkPanID:
                return Gen3SetupStrings.ControlPanel.Mesh.NetworkPanID
            case .meshInfoNetworkChannel:
                return Gen3SetupStrings.ControlPanel.Mesh.NetworkChannel
            case .meshInfoNetworkDeviceCount:
                return Gen3SetupStrings.ControlPanel.Mesh.DeviceCount
            case .meshInfoDeviceRole:
                return Gen3SetupStrings.ControlPanel.Mesh.DeviceRole

            case .actionLeaveMeshNetwork:
                return Gen3SetupStrings.ControlPanel.Mesh.LeaveNetwork
            case .actionAddToMeshNetwork:
                return Gen3SetupStrings.ControlPanel.Mesh.AddToNetwork
            case .actionPromoteToGateway:
                return Gen3SetupStrings.ControlPanel.Mesh.PromoteToGateway
            case .actionDemoteFromGateway:
                return Gen3SetupStrings.ControlPanel.Mesh.DemoteFromGateway

}
    }

    func getCellDetails(context: Gen3SetupContext) -> String? {
        switch self {
            case .actionChangeSimStatus:
                if context.targetDevice.sim!.status! == .activate {
                    return Gen3SetupStrings.ControlPanel.Cellular.Active
                } else if (context.targetDevice.sim!.status! == .inactiveDataLimitReached) {
                    return Gen3SetupStrings.ControlPanel.Cellular.Paused
                } else if (context.targetDevice.sim!.status! == .inactiveNeverActivated) {
                    return Gen3SetupStrings.ControlPanel.Cellular.NeverActivated
                } else {
                    return Gen3SetupStrings.ControlPanel.Cellular.Inactive
                }
            case .actionChangePinsStatus:
                return context.targetDevice.ethernetDetectionFeature! ? Gen3SetupStrings.ControlPanel.Ethernet.Active : Gen3SetupStrings.ControlPanel.Ethernet.Inactive
            case .actionChangeDataLimit:
                return context.targetDevice.sim!.dataLimit! > -1 ? Gen3SetupStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{dataLimit}}", with: String(context.targetDevice.sim!.dataLimit!)) : Gen3SetupStrings.ControlPanel.Cellular.DataLimit.DataLimitValueNone
            case .name:
                return context.targetDevice.name
            case .notes:
                return context.targetDevice.notes

            case .meshInfoNetworkName:
                if let _ = context.targetDevice.meshNetworkInfo {
                    return context.targetDevice.meshNetworkInfo!.name
                } else {
                    return Gen3SetupStrings.ControlPanel.Mesh.NoNetworkInfo
                }
            case .meshInfoNetworkID:
                return context.targetDevice.meshNetworkInfo!.networkID
            case .meshInfoNetworkExtPanID:
                return context.targetDevice.meshNetworkInfo!.extPanID
            case .meshInfoNetworkPanID:
                return String(context.targetDevice.meshNetworkInfo!.panID)
            case .meshInfoNetworkChannel:
                return String(context.targetDevice.meshNetworkInfo!.channel)
            case .meshInfoNetworkDeviceCount:
                if let apiNetworks = context.apiNetworks {
                    for network in apiNetworks {
                        if (context.targetDevice.meshNetworkInfo!.networkID == network.id) {
                            return String(network.deviceCount)
                        }
                    }
                }
                return nil
            case .meshInfoDeviceRole:
                //BUG: fix a bug where this is called for device that has no network role
                return (context.targetDevice.networkRole ?? .node) == .gateway ? Gen3SetupStrings.ControlPanel.Mesh.DeviceRoleGateway : Gen3SetupStrings.ControlPanel.Mesh.DeviceRoleNode


            case .wifiInfoSSID:
                if let _ = context.targetDevice.wifiNetworkInfo {
                    return context.targetDevice.wifiNetworkInfo!.ssid
                } else {
                    return Gen3SetupStrings.ControlPanel.Wifi.NoNetworkInfo
                }
            case .wifiInfoChannel:
                return String(context.targetDevice.wifiNetworkInfo!.channel)
            case .wifiInfoRSSI:
                return String(context.targetDevice.wifiNetworkInfo!.rssi)

            default:
                return nil
        }
    }

    func getCellEnabled(context: Gen3SetupContext) -> Bool {
        switch self {
            case .actionChangeSimStatus:
                return false
            case .meshInfoNetworkName, .meshInfoNetworkID, .meshInfoNetworkExtPanID, .meshInfoNetworkPanID, .meshInfoNetworkPanID, .meshInfoNetworkChannel, .meshInfoDeviceRole, .meshInfoNetworkDeviceCount:
                return false
            case .wifiInfoChannel, .wifiInfoRSSI, .wifiInfoSSID:
                return false
            case .actionChangeDataLimit:
                return context.targetDevice.sim!.dataLimit! > -1
            default:
                return true
        }
    }

    func getIcon(context: Gen3SetupContext) -> UIImage? {
        switch self {
            case .wifi:
                return UIImage(named: "Gen3SetupWifiIcon")
            case .cellular:
                return UIImage(named: "Gen3SetupCellularIcon")
            case .ethernet:
                return UIImage(named: "Gen3SetupEthernetIcon")
            case .mesh:
                return UIImage(named: "Gen3SetupMeshIcon")
            default:
                return nil
        }
    }

    func getDisclosureIndicator(context: Gen3SetupContext) -> UITableViewCell.AccessoryType {
        switch self {
            case .unclaim, .actionLeaveMeshNetwork:
                return .none
            case .meshInfoNetworkName, .meshInfoNetworkID, .meshInfoNetworkExtPanID, .meshInfoNetworkPanID, .meshInfoNetworkPanID, .meshInfoNetworkChannel, .meshInfoNetworkDeviceCount, .meshInfoDeviceRole:
                return .none
            case .wifiInfoChannel, .wifiInfoRSSI, .wifiInfoSSID:
                return .none
            case .actionChangeSimStatus:
                return .none
            default:
                return .disclosureIndicator
        }
    }


    static func prepareTableView(_ tableView: UITableView) {
        tableView.register(UINib.init(nibName: "Gen3SetupBasicCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupBasicCell")
        tableView.register(UINib.init(nibName: "Gen3SetupBasicIconCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupBasicIconCell")
        tableView.register(UINib.init(nibName: "Gen3SetupButtonCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupButtonCell")
        tableView.register(UINib.init(nibName: "Gen3SetupSubtitleCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupSubtitleCell")
        tableView.register(UINib.init(nibName: "Gen3SetupHorizontalDetailCell", bundle: nil), forCellReuseIdentifier: "Gen3SetupHorizontalDetailCell")
    }

    func getConfiguredCell(_ tableView: UITableView, context: Gen3SetupContext) -> Gen3SetupCell {
        let image = self.getIcon(context: context)
        let detail = self.getCellDetails(context: context)
        let enabled = self.getCellEnabled(context: context)
        let accessoryType = self.getDisclosureIndicator(context: context)

        var cell:Gen3SetupCell! = nil

        if (self == .unclaim || self == .actionLeaveMeshNetwork) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupButtonCell") as! Gen3SetupCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.RedTextColor : ParticleStyle.DetailsTextColor)
        } else if (self == .actionChangeSimStatus || self == .actionChangePinsStatus) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupSubtitleCell") as! Gen3SetupCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            cell.cellSubtitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
            cell.cellSubtitleLabel.text = detail
        } else if image != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupBasicIconCell") as! Gen3SetupCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)
        } else if detail != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupHorizontalDetailCell") as! Gen3SetupCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)

            cell.cellDetailLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.DetailsTextColor)
            cell.cellDetailLabel.text = detail
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gen3SetupBasicCell") as! Gen3SetupCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)
        }

        cell.tintColor = ParticleStyle.DisclosureIndicatorColor
        cell.accessoryType = accessoryType
        cell.cellTitleLabel.text = self.getCellTitle(context: context)
        cell.cellIconImageView?.image = image

        return cell
    }
}
