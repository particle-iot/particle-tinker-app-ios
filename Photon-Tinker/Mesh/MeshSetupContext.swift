//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupContext: NSObject {
    var delegate: MeshSetupFlowManagerDelegate!

    var bluetoothManager: MeshSetupBluetoothConnectionManager!
    var bluetoothReady: Bool = false

    var targetDevice: MeshDevice! = MeshDevice()
    var commissionerDevice: MeshDevice?

    var selectedWifiNetworkInfo: MeshSetupNewWifiNetworkInfo?

    var selectedNetworkMeshInfo: MeshSetupNetworkInfo?
    var selectedNetworkPassword: String?

    var newNetworkName: String?
    var newNetworkPassword: String?
    var newNetworkId: String?

    var userSelectedToLeaveNetwork: Bool?
    var userSelectedToUpdateFirmware: Bool?
    var userSelectedToSetupMesh: Bool?

    var pricingInfo: ParticlePricingInfo?
    var pricingRequirementsAreMet: Bool?
    var apiNetworks: [ParticleNetwork]?

    //to prevent long running actions from executing
    var canceled = false

    //allows to pause flow at the end of the step if there's something that UI wants to show.
    var paused = false
}
