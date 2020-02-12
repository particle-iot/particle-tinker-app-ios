//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepJoinSelectedNetwork : Gen3SetupStep {

    private var joinerPrepared: Bool = false
    private var joinerAdded: Bool = false
    private var networkJoined: Bool = false
    private var failureReason: Gen3SetupFlowError? = nil


    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.commissionerDevice?.isCommissionerMode == nil ||  context.commissionerDevice?.isCommissionerMode! == false) {
            self.startCommissioner()
        } else if (!joinerPrepared) {
            self.prepareJoiner()
        } else if (!joinerAdded) {
            self.addJoiner()
        } else if (self.failureReason != nil) {
            self.attemptRecoveryStart()
        } else if (!networkJoined) {
            self.joinNetwork()
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        joinerPrepared = false
        joinerAdded = false
        networkJoined = false
        failureReason = nil
    }


    private func startCommissioner() {
        guard let context = self.context else {
            return
        }

        context.delegate.gen3SetupDidEnterState(self, state: .JoiningNetworkStarted)

        /// NOT_ALLOWED: The client is not authenticated
        context.commissionerDevice!.transceiver?.sendStartCommissioner { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendStartCommissioner: \(result.description())")

            if result == .NONE {
                context.commissionerDevice?.isCommissionerMode = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func prepareJoiner() {
        guard let context = self.context else {
            return
        }

        /// ALREADY_EXIST: The device is already a member of a network
        /// NOT_ALLOWED: The client is not authenticated
        context.targetDevice.transceiver?.sendPrepareJoiner(networkInfo: context.selectedNetworkMeshInfo!) {
            [weak self, weak context] result, eui64, password in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendPrepareJoiner sent networkInfo: \(context.selectedNetworkMeshInfo!)")

            self.log("targetDevice.sendPrepareJoiner: \(result.description())")
            if (result == .NONE) {
                context.targetDevice.joinerCredentials = (eui64: eui64!, password: password!)
                self.joinerPrepared = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func addJoiner() {
        guard let context = self.context else {
            return
        }

        context.delegate.gen3SetupDidEnterState(self, state: .JoiningNetworkStep1Done)

        /// NO_MEMORY: No memory available to add the joiner
        /// INVALID_STATE: The commissioner role is not started
        /// NOT_ALLOWED: The client is not authenticated
        context.commissionerDevice!.transceiver?.sendAddJoiner(eui64: context.targetDevice.joinerCredentials!.eui64, password: context.targetDevice.joinerCredentials!.password) {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendAddJoiner: \(result.description())")

            if (result == .NONE) {
                self.log("Delaying call to joinNetwork")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self, weak context] in
                    guard let self = self, let context = context, !context.canceled else {
                        return
                    }

                    self.joinerAdded = true
                    self.start()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func joinNetwork() {
        guard let context = self.context else {
            return
        }

        self.log("Sending join network")

        /// NOT_FOUND: No joinable network was found
        /// TIMEOUT: The join process timed out
        /// NOT_ALLOWED: Invalid security credentials
        context.targetDevice.transceiver?.sendJoinNetwork {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendJoinNetwork: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.networkRole = .node

                self.networkJoined = true
                self.failureReason = nil
                self.start()
            } else if (result == .NOT_ALLOWED) {
                self.networkJoined = false
                self.failureReason = .DeviceIsNotAllowedToJoinNetwork
                self.start()
            } else if (result == .NOT_FOUND) {
                self.networkJoined = false
                self.failureReason = .DeviceIsUnableToFindNetworkToJoin
                self.start()
            } else if (result == .TIMEOUT) {
                self.networkJoined = false
                self.failureReason = .DeviceTimeoutWhileJoiningNetwork
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }

         }
    }


    private func attemptRecoveryStart() {
        guard let context = self.context else {
            return
        }

        context.commissionerDevice!.transceiver?.sendStopCommissioner {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendStopCommissioner: \(result.description())")

            if (result == .NONE) {
                context.commissionerDevice?.isCommissionerMode = false
                self.attemptRecoveryEnd()
            } else {
                //if there's one more error here, do not display message cause that
                //most likely won't be handeled properly anyway
                self.fail(withReason: self.failureReason!)
                self.reset()
            }
        }

    }

    private func attemptRecoveryEnd() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendLeaveNetwork() {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendLeaveNetwork: \(result.description())")

            self.fail(withReason: self.failureReason!)
            self.reset()
        }
    }
}
