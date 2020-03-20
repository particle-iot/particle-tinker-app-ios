//
//  Gen3SetupFlowDefinitions.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 10/10/2018.
//  Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation

internal struct Gen3SetupNetworkCellInfo {
    var name: String
    var extPanID: String
    var userOwned: Bool = false
    var deviceCount: UInt? = nil
}

enum Gen3SetupFlowState {
    case TargetDeviceConnecting
    case TargetDeviceDiscovered
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
    case CommissionerDeviceDiscovered
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

//delegate required to request / deliver information from / to the UI
protocol Gen3SetupFlowRunnerDelegate {

    //control panel
    func gen3SetupDidRequestToSwitchToControlPanel(_ sender: Gen3SetupStep, device: ParticleDevice)
    //func setSwitchToControlPanel(switch: Bool) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToSelectSimStatus(_ sender: Gen3SetupStep)
    //func setTargetSimStatus(simActive: Bool) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToSelectSimDataLimit(_ sender: Gen3SetupStep)
    //func setSimDataLimit(dataLimit: Int) -> Gen3SetupFlowError?
    func gen3SetupDidCompleteControlPanelFlow(_ sender: Gen3SetupStep)

    //setup flow
    func gen3SetupDidRequestTargetDeviceInfo(_ sender: Gen3SetupStep)
    //func setTargetDeviceInfo(dataMatrix: Gen3SetupDataMatrix) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToSelectEthernetStatus(_ sender: Gen3SetupStep)
    //func setTargetUseEthernet(useEthernet: Bool) -> Gen3SetupFlowError?

    func gen3SetupDidRequestToUpdateFirmware(_ sender: Gen3SetupStep)
    //func setTargetPerformFirmwareUpdate(update: Bool) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToLeaveNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkInfo)
    //func setTargetDeviceLeaveNetwork(leave: Bool) -> Gen3SetupFlowError?

    func gen3SetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: Gen3SetupStep)
    //func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToSelectOrCreateNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo])
    //func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> Gen3SetupFlowError?
    //func rescanNetworks() -> Gen3SetupFlowError?

    func gen3SetupDidRequestToShowPricingInfo(_ sender: Gen3SetupStep, info: ParticlePricingInfo)
    //func setPricingImpactDone() -> Gen3SetupFlowError?
    func gen3SetupDidRequestToShowInfo(_ sender: Gen3SetupStep)
    //func setInfoDone() -> Gen3SetupFlowError?

    func gen3SetupDidRequestToEnterDeviceName(_ sender: Gen3SetupStep)
    //func setDeviceName(name: String, onComplete:@escaping (Gen3SetupFlowError?) -> ())
    func gen3SetupDidRequestToAddOneMoreDevice(_ sender: Gen3SetupStep)
    //func setAddOneMoreDevice(addOneMoreDevice: Bool) -> Gen3SetupFlowError?

    func gen3SetupDidRequestToEnterNewNetworkPassword(_ sender: Gen3SetupStep)
    //func setNewNetworkPassword(password: String) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToEnterNewNetworkName(_ sender: Gen3SetupStep)
    //func setNewNetworkName(name: String) -> Gen3SetupFlowError?


    func gen3SetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: Gen3SetupStep)
    //func setSelectedWifiNetwork(selectedNetwork: Gen3SetupNewWifiNetworkInfo) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToSelectWifiNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNewWifiNetworkInfo])
    //func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (Gen3SetupFlowError?) -> ())
    //func rescanNetworks() -> Gen3SetupFlowError?

    func gen3SetupDidRequestToSelectNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo])
    //func setSelectedNetwork(selectedNetworkExtPanID: String) -> Gen3SetupFlowError?
    //func rescanNetworks() -> Gen3SetupFlowError?

    func gen3SetupDidRequestCommissionerDeviceInfo(_ sender: Gen3SetupStep)
    //func setCommissionerDeviceInfo(dataMatrix: Gen3SetupDataMatrix) -> Gen3SetupFlowError?
    func gen3SetupDidRequestToEnterSelectedNetworkPassword(_ sender: Gen3SetupStep)
    //func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (Gen3SetupFlowError?) -> ())

    func gen3SetupDidCreateNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkCellInfo)
    func gen3SetupDidEnterState(_ sender: Gen3SetupStep, state: Gen3SetupFlowState)
    func gen3SetupError(_ sender: Gen3SetupStep, error: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity, nsError: Error?)
}

extension Gen3SetupFlowRunnerDelegate {
    //control panel
    func gen3SetupDidRequestToSwitchToControlPanel(_ sender: Gen3SetupStep, device: ParticleDevice) { fatalError("Not implemented") }
    func gen3SetupDidRequestToSelectSimStatus(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidCompleteControlPanelFlow(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToSelectSimDataLimit(_ sender: Gen3SetupStep) { fatalError("Not implemented") }

    //setup flow
    func gen3SetupDidRequestTargetDeviceInfo(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToSelectEthernetStatus(_ sender: Gen3SetupStep) { fatalError("Not implemented") }

    func gen3SetupDidRequestToUpdateFirmware(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToLeaveNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkInfo) { fatalError("Not implemented") }

    func gen3SetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToSelectOrCreateNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo]) { fatalError("Not implemented") }

    func gen3SetupDidRequestToShowPricingInfo(_ sender: Gen3SetupStep, info: ParticlePricingInfo) { fatalError("Not implemented") }
    func gen3SetupDidRequestToShowInfo(_ sender: Gen3SetupStep) { fatalError("Not implemented") }

    func gen3SetupDidRequestToEnterDeviceName(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToAddOneMoreDevice(_ sender: Gen3SetupStep) { fatalError("Not implemented") }

    func gen3SetupDidRequestToEnterNewNetworkPassword(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToEnterNewNetworkName(_ sender: Gen3SetupStep) { fatalError("Not implemented") }


    func gen3SetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToSelectWifiNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNewWifiNetworkInfo]) { fatalError("Not implemented") }

    func gen3SetupDidRequestToSelectNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo]) { fatalError("Not implemented") }

    func gen3SetupDidRequestCommissionerDeviceInfo(_ sender: Gen3SetupStep) { fatalError("Not implemented") }
    func gen3SetupDidRequestToEnterSelectedNetworkPassword(_ sender: Gen3SetupStep) { fatalError("Not implemented") }

    func gen3SetupDidCreateNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkCellInfo) { fatalError("Not implemented") }
    func gen3SetupDidEnterState(_ sender: Gen3SetupStep, state: Gen3SetupFlowState) { fatalError("Not implemented") }
    func gen3SetupError(_ sender: Gen3SetupStep, error: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity, nsError: Error?) { fatalError("Not implemented") }
}












