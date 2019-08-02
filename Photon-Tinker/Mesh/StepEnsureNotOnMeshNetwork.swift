//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureNotOnMeshNetwork: MeshSetupStep {
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
        guard let context = self.context else {
            return
        }

        if (!meshNetworkInfoLoaded) {
            self.getTargetDeviceMeshNetworkInfo()
        } else if (context.userSelectedToLeaveNetwork == nil) {
            self.getUserSelectedToLeaveNetwork()
        } else if (context.userSelectedToLeaveNetwork! == false) {
            //user decided to cancel setup, and we want to get his device in normal mode.
            self.log("stopping listening mode?")
            self.stopTargetDeviceListening()
        } else if (!leftNetworkOnAPI) { //context.userSelectedToLeaveNetwork! == true
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
        context?.targetDevice.transceiver!.sendGetNetworkInfo { [weak self, weak context] result, networkInfo in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetNetworkInfo: \(result.description())")
            self.log("\(networkInfo as Optional)");

            if (result == .NOT_FOUND) {
                self.meshNetworkInfoLoaded = true
                context.targetDevice.meshNetworkInfo = nil
                self.start()
            } else if (result == .NONE) {
                self.meshNetworkInfoLoaded = true
                context.targetDevice.meshNetworkInfo = networkInfo
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getUserSelectedToLeaveNetwork() {
        guard let context = self.context else {
            return
        }

        if let network = context.targetDevice.meshNetworkInfo {
            if (network.networkID.count == 0) {
                let _ = self.setTargetDeviceLeaveNetwork(leave: true)
            } else {
                context.delegate.meshSetupDidRequestToLeaveNetwork(self, network: network)
            }
        } else {
            let _ = self.setTargetDeviceLeaveNetwork(leave: true)
        }
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.userSelectedToLeaveNetwork = leave
        self.log("setTargetDeviceLeaveNetwork: \(leave)")

        self.start()
        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.userSelectedToLeaveNetwork = nil
        context.targetDevice.meshNetworkInfo = nil
    }

    private func targetDeviceLeaveAPINetwork() {
        guard let context = self.context else {
            return
        }

        self.log("sening remove device network info to API")

        ParticleCloud.sharedInstance().removeDeviceNetworkInfo(context.targetDevice.deviceId!) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
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
        context?.targetDevice.transceiver!.sendLeaveNetwork { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.didReceiveLeaveNetworkReply: \(result.description())")

            if (result == .NONE) {
                self.leftNetworkOnDevice = true
                context.targetDevice.meshNetworkInfo = nil
                context.targetDevice.isListeningMode = nil
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func getAPINetworks() {
        ParticleCloud.sharedInstance().getNetworks { [weak self, weak context] networks, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            self.apiNetworksLoaded = true

            if let networks = networks {
                context.apiNetworks = networks
            } else {
                context.apiNetworks = []
            }

            self.stepCompleted()
        }
    }




    private func stopTargetDeviceListening() {
        context?.targetDevice.transceiver!.sendStopListening { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopListening: \(result.description())")

            if (context.canceled) {
                return
            }

            if (result == .NONE) {
                context.delegate.meshSetupDidEnterState(self, state: .SetupCanceled)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
