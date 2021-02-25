//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class Gen3SetupContext: NSObject {
    var delegate: Gen3SetupFlowRunnerDelegate!
    var stepDelegate: Gen3SetupStepDelegate!

    var bluetoothManager: Gen3SetupBluetoothConnectionManager!
    var bluetoothReady: Bool = false

    var targetDevice: Gen3SetupDevice! = Gen3SetupDevice()
    var commissionerDevice: Gen3SetupDevice?

    var selectedWifiNetworkInfo: Gen3SetupNewWifiNetworkInfo?
    var selectedForRemovalWifiNetworkInfo: Gen3SetupKnownWifiNetworkInfo?

    var selectedNetworkMeshInfo: Gen3SetupNetworkInfo?
    var selectedNetworkPassword: String?

    var newNetworkName: String?
    var newNetworkPassword: String?
    var newNetworkId: String?

    var userSelectedToLeaveNetwork: Bool?
    var userSelectedToUpdateFirmware: Bool?
    var userSelectedToSetupMesh: Bool?
    var userSelectedToCreateNetwork: Bool?

    var apiNetworks: [ParticleNetwork]?

    //to prevent long running actions from executing
    var canceled = false

    //allows to pause flow at the end of the step if there's something that UI wants to show.
    var paused = false
}
