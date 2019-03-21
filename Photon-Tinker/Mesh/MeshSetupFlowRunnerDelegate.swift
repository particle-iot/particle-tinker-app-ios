//
//  MeshSetupFlowDefinitions.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 10/10/2018.
//  Copyright © 2018 spark. All rights reserved.
//

import Foundation

internal struct MeshSetupNetworkCellInfo {
    var name: String
    var extPanID: String
    var userOwned: Bool = false
    var deviceCount: UInt? = nil
}

//delegate required to request / deliver information from / to the UI
protocol MeshSetupFlowRunnerDelegate {
    func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep)

    func meshSetupDidRequestToUpdateFirmware(_ sender: MeshSetupStep)
    func meshSetupDidRequestToLeaveNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkInfo)


    //create flow
    func meshSetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: MeshSetupStep)
    func meshSetupDidRequestToSelectOrCreateNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo])

    func meshSetupDidRequestToShowPricingInfo(_ sender: MeshSetupStep, info: ParticlePricingInfo)
    func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep)

    func meshSetupDidRequestToEnterDeviceName(_ sender: MeshSetupStep)
    func meshSetupDidRequestToAddOneMoreDevice(_ sender: MeshSetupStep)

    func meshSetupDidRequestToEnterNewNetworkPassword(_ sender: MeshSetupStep)
    func meshSetupDidRequestToEnterNewNetworkName(_ sender: MeshSetupStep)
    func meshSetupDidCreateNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkCellInfo)

    func meshSetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: MeshSetupStep)
    func meshSetupDidRequestToSelectWifiNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNewWifiNetworkInfo])

    //joiner flow
    func meshSetupDidRequestToSelectNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo])
    func meshSetupDidRequestCommissionerDeviceInfo(_ sender: MeshSetupStep)
    func meshSetupDidRequestToEnterSelectedNetworkPassword(_ sender: MeshSetupStep)

    func meshSetupDidEnterState(_ sender: MeshSetupStep, state: MeshSetupFlowState)
    func meshSetupError(_ sender: MeshSetupStep, error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?)
}

protocol MeshSetupDataConsumer {
    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError?

    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError?
    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError?

    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError?
    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError?

    func setPricingImpactDone() -> MeshSetupFlowError?
    func setInfoDone() -> MeshSetupFlowError?

    func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ())
    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError?

    func setNewNetworkName(name: String) -> MeshSetupFlowError?
    func setNewNetworkPassword(password: String) -> MeshSetupFlowError?
    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError?
    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ())

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError?
    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError?
    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ())

    func rescanNetworks() -> MeshSetupFlowError?
}



enum MeshSetupFlowState {
    case TargetDeviceConnecting
    case TargetDeviceConnected
    case TargetDeviceReady

    case TargetDeviceScanningForNetworks
    case TargetInternetConnectedDeviceScanningForNetworks
    case TargetDeviceScanningForWifiNetworks

    case TargetDeviceConnectingToInternetStarted
    case TargetDeviceConnectingToInternetStep0Done //used for activating sim card only
    case TargetDeviceConnectingToInternetStep1Done
    case TargetDeviceConnectingToInternetCompleted

    case CommissionerDeviceConnecting
    case CommissionerDeviceConnected
    case CommissionerDeviceReady

    case JoiningNetworkStarted
    case JoiningNetworkStep1Done
    case JoiningNetworkStep2Done
    case JoiningNetworkCompleted

    case FirmwareUpdateProgress
    case FirmwareUpdateFileComplete
    case FirmwareUpdateComplete

    case CreateNetworkStarted
    case CreateNetworkStep1Done
    case CreateNetworkCompleted

    case SetupCanceled
}











