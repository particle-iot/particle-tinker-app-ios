//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureTargetDeviceIsNotOnMeshNetwork : MeshSetupStep {
    private var meshNetworkInfoLoaded = false
    private var leftNetworkOnAPI = false
    private var leftNetworkOnDevice = false
    private var apiNetworksLoaded = false

    override func reset() {
        meshNetworkInfoLoaded = false
        leftNetworkOnAPI = false
        leftNetworkOnDevice = false
        apiNetworksLoaded = false
    }

    override func start() {
        if (!meshNetworkInfoLoaded) {
            self.getTargetDeviceMeshNetworkInfo()
        } else if (self.context.userSelectedToLeaveNetwork == nil) {
            self.getUserSelectedToLeaveNetwork()
        } else if (self.context.userSelectedToLeaveNetwork! == false) {
            //user decided to cancel setup, and we want to get his device in normal mode.
            self.log("stopping listening mode?")
            self.stopTargetDeviceListening()
        } else if (!leftNetworkOnAPI) { //self.context.userSelectedToLeaveNetwork! == true
            //forcing this command even on devices with no network info helps with the joining process
            self.targetDeviceLeaveAPINetwork()
        } else if (!leftNetworkOnDevice) {
            self.targetDeviceLeaveMeshNetwork()
        } else if (!apiNetworksLoaded) {
            self.getAPINetworks()
        } else {
            self.stepCompleted()
        }
    }

    private func getTargetDeviceMeshNetworkInfo() {
        self.context.targetDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in

            self.log("targetDevice.sendGetNetworkInfo: \(result.description())")
            self.log("\(networkInfo as Optional)");
            if (self.context.canceled) {
                return
            }

            if (result == .NOT_FOUND) {
                self.meshNetworkInfoLoaded = true
                self.context.targetDevice.meshNetworkInfo = nil
                self.start()
            } else if (result == .NONE) {
                self.meshNetworkInfoLoaded = true
                self.context.targetDevice.meshNetworkInfo = networkInfo
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getUserSelectedToLeaveNetwork() {
        if let network = self.context.targetDevice.meshNetworkInfo {
            if (network.networkID.count == 0) {
                let _ = self.setTargetDeviceLeaveNetwork(leave: true)
            } else {
                self.context.delegate.meshSetupDidRequestToLeaveNetwork(network: network)
            }
        } else {
            let _ = self.setTargetDeviceLeaveNetwork(leave: true)
        }
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError? {
        self.context.userSelectedToLeaveNetwork = leave
        self.log("setTargetDeviceLeaveNetwork: \(leave)")

        self.start()
        return nil
    }



    private func targetDeviceLeaveAPINetwork() {
        self.log("sening remove device network info to API")

        ParticleCloud.sharedInstance().removeDeviceNetworkInfo(self.context.targetDevice.deviceId!) {
            error in

            if (self.context.canceled) {
                return
            }


            self.log("removeDevice error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToLeaveNetwork, nsError: error)
                return
            }

            self.leftNetworkOnAPI = true
            self.start()
        }
    }

    private func targetDeviceLeaveMeshNetwork() {
        self.context.targetDevice.transceiver!.sendLeaveNetwork { result in
            self.log("targetDevice.didReceiveLeaveNetworkReply: \(result.description())")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.leftNetworkOnDevice = true
                self.context.targetDevice.meshNetworkInfo = nil
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func getAPINetworks() {
        ParticleCloud.sharedInstance().getNetworks { networks, error in
            if (self.context.canceled) {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            self.apiNetworksLoaded = true

            if let networks = networks {
                self.context.apiNetworks = networks
            } else {
                self.context.apiNetworks = []
            }

            self.stepCompleted()
        }
    }




    private func stopTargetDeviceListening() {
        self.context.targetDevice.transceiver!.sendStopListening { result in
            self.log("targetDevice.sendStopListening: \(result.description())")

            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.context.delegate.meshSetupDidEnterState(state: .SetupCanceled)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
