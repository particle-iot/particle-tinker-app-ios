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
    case ControlPanelFlowComplete
}

//delegate required to request / deliver information from / to the UI
protocol MeshSetupFlowRunnerDelegate {
    func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep)
    //func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError?
    func meshSetupDidRequestToSelectEthernetStatus(_ sender: MeshSetupStep)
    //func setTargetUseEthernet(useEthernet: Bool) -> MeshSetupFlowError?


    func meshSetupDidRequestToUpdateFirmware(_ sender: MeshSetupStep)
    //func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError?
    func meshSetupDidRequestToLeaveNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkInfo)
    //func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError?


    //create flow
    func meshSetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: MeshSetupStep)
    //func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError?
    func meshSetupDidRequestToSelectOrCreateNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo])
    //func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError?
    //func rescanNetworks() -> MeshSetupFlowError?

    func meshSetupDidRequestToShowPricingInfo(_ sender: MeshSetupStep, info: ParticlePricingInfo)
    //func setPricingImpactDone() -> MeshSetupFlowError?
    func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep)
    //func setInfoDone() -> MeshSetupFlowError?

    func meshSetupDidRequestToEnterDeviceName(_ sender: MeshSetupStep)
    //func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ())
    func meshSetupDidRequestToAddOneMoreDevice(_ sender: MeshSetupStep)
    //func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError?

    func meshSetupDidRequestToEnterNewNetworkPassword(_ sender: MeshSetupStep)
    //func setNewNetworkPassword(password: String) -> MeshSetupFlowError?
    func meshSetupDidRequestToEnterNewNetworkName(_ sender: MeshSetupStep)
    //func setNewNetworkName(name: String) -> MeshSetupFlowError?


    func meshSetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: MeshSetupStep)
    //func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError?
    func meshSetupDidRequestToSelectWifiNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNewWifiNetworkInfo])
    //func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ())
    //func rescanNetworks() -> MeshSetupFlowError?

    func meshSetupDidRequestToSelectNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo])
    //func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError?
    //func rescanNetworks() -> MeshSetupFlowError?

    func meshSetupDidRequestCommissionerDeviceInfo(_ sender: MeshSetupStep)
    //func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError?
    func meshSetupDidRequestToEnterSelectedNetworkPassword(_ sender: MeshSetupStep)
    //func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ())


    func meshSetupDidCreateNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkCellInfo)
    func meshSetupDidEnterState(_ sender: MeshSetupStep, state: MeshSetupFlowState)
    func meshSetupError(_ sender: MeshSetupStep, error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?)
}

extension MeshSetupFlowRunnerDelegate {
    func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToSelectEthernetStatus(_ sender: MeshSetupStep) { fatalError("Not implemented") }

    func meshSetupDidRequestToUpdateFirmware(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToLeaveNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkInfo) { fatalError("Not implemented") }


    //create flow
    func meshSetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToSelectOrCreateNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo]) { fatalError("Not implemented") }

    func meshSetupDidRequestToShowPricingInfo(_ sender: MeshSetupStep, info: ParticlePricingInfo) { fatalError("Not implemented") }
    func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep) { fatalError("Not implemented") }

    func meshSetupDidRequestToEnterDeviceName(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToAddOneMoreDevice(_ sender: MeshSetupStep) { fatalError("Not implemented") }

    func meshSetupDidRequestToEnterNewNetworkPassword(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToEnterNewNetworkName(_ sender: MeshSetupStep) { fatalError("Not implemented") }


    func meshSetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToSelectWifiNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNewWifiNetworkInfo]) { fatalError("Not implemented") }

    func meshSetupDidRequestToSelectNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo]) { fatalError("Not implemented") }

    func meshSetupDidRequestCommissionerDeviceInfo(_ sender: MeshSetupStep) { fatalError("Not implemented") }
    func meshSetupDidRequestToEnterSelectedNetworkPassword(_ sender: MeshSetupStep) { fatalError("Not implemented") }


    func meshSetupDidCreateNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkCellInfo) { fatalError("Not implemented") }
    func meshSetupDidEnterState(_ sender: MeshSetupStep, state: MeshSetupFlowState) { fatalError("Not implemented") }
    func meshSetupError(_ sender: MeshSetupStep, error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) { fatalError("Not implemented") }
}












