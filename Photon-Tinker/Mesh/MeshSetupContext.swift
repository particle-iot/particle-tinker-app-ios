//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupContext: NSObject {
    var delegate: MeshSetupFlowManagerDelegate!

    var bluetoothManager: MeshSetupBluetoothConnectionManager!
    var bluetoothReady: Bool = false
    {
        didSet {
            if (!bluetoothReady) {
                //if we are waiting for the reply = trigger timeout
                if let targetDeviceTransceiver = self.targetDevice.transceiver {
                    targetDeviceTransceiver.triggerTimeout()
                }

                //if we are waiting for the reply = trigger timeout
                if let commissionerDeviceTransceiver = self.commissionerDevice?.transceiver {
                    commissionerDeviceTransceiver.triggerTimeout()
                }
            }
        }
    }

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

    func resetFlowFlags() {
        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner

        self.newNetworkPassword = nil
        self.newNetworkName = nil
        self.newNetworkId = nil

        self.apiNetworks = nil

        self.userSelectedToLeaveNetwork = nil
        self.userSelectedToUpdateFirmware = nil
        self.userSelectedToSetupMesh = nil

        self.pricingInfo = nil
        self.pricingRequirementsAreMet = nil
    }

    private func resetFirmwareFlashFlags() {

        //reset all the important flags
        self.targetDevice.firmwareVersion = nil
        self.targetDevice.ncpVersion = nil
        self.targetDevice.ncpModuleVersion = nil
        self.targetDevice.supportsCompressedOTAUpdate = nil
        self.targetDevice.nextFirmwareBinaryURL = nil
        self.targetDevice.nextFirmwareBinaryFilePath = nil
    }
}
