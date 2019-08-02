//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureLatestFirmware: MeshSetupStep {

    private var chunkSize: Int?
    private var chunkIdx: Int?
    private var firmwareData: Data?

    private var nextFirmwareBinaryURL: String?
    private var nextFirmwareBinaryFilePath: String?


    private var preparedForReboot: Bool = false
    private var firmwareUpdateFinished: Bool = false


//    //Slave Latency ≤ 30
//    //2 seconds ≤ connSupervisionTimeout ≤ 6 seconds
//    //Interval Min modulo 15 ms == 0
//    //Interval Min ≥ 15 ms
//    //
//    //One of the following:
//    //  Interval Min + 15 ms ≤ Interval Max
//    //  Interval Min == Interval Max == 15 ms
//    //
//    //Interval Max * (Slave Latency + 1) ≤ 2 seconds
//    //Interval Max * (Slave Latency + 1) * 3 <connSupervisionTimeout
//
    override func reset() {
        self.preparedForReboot = false
        self.firmwareUpdateFinished = false

        self.nextFirmwareBinaryURL = nil
        self.nextFirmwareBinaryFilePath = nil

        self.chunkSize = nil
        self.chunkIdx = nil
        self.firmwareData = nil
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.firmwareVersion == nil) {
            self.getTargetDeviceFirmwareVersion()
        } else if (context.targetDevice.supportsCompressedOTAUpdate == nil) {
            self.checkTargetDeviceSupportsCompressedOTA()
        } else if (context.targetDevice.ncpVersionReceived == nil) {
            self.checkNcpFirmwareVersion()
        } else if (context.targetDevice.isSetupDone == nil) {
            self.checkTargetDeviceIsSetupDone()
        } else if (nextFirmwareBinaryURL == nil) {
            self.checkNeedsOTAUpdate()
        } else if (context.userSelectedToUpdateFirmware == nil) {
            context.delegate.meshSetupDidRequestToUpdateFirmware(self)
        } else if (!self.preparedForReboot) {
            self.prepareForTargetDeviceReboot()
        } else if(nextFirmwareBinaryFilePath == nil) {
            self.prepareOTABinary()
        } else if (firmwareData == nil || chunkSize == nil) {
            self.startFirmwareUpdate()
        } else if (!self.isFileFullyFlashed()) {
            self.sendFirmwareUpdateChunk()
        } else if (!firmwareUpdateFinished) {
            self.finishFirmwareUpdate()
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.userSelectedToUpdateFirmware == nil
    }

    private func getTargetDeviceFirmwareVersion() {
        context?.targetDevice.transceiver!.sendGetSystemVersion { [weak self, weak context] result, version in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetSystemVersion: \(result.description()), version: \(version as Optional)")

            if (result == .NONE) {
                context.targetDevice.firmwareVersion = version!
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceSupportsCompressedOTA() {
        context?.targetDevice.transceiver!.sendGetSystemCapabilities { [weak self, weak context] result, capability in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetSystemCapabilities: \(result.description()), capability: \(capability?.rawValue as Optional)")

            if (result == .NONE) {
                context.targetDevice.supportsCompressedOTAUpdate = (capability! == MeshSetupSystemCapability.compressedOta)
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNcpFirmwareVersion() {
        context?.targetDevice.transceiver!.sendGetNcpFirmwareVersion { [weak self, weak context] result, version, moduleVersion in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetNcpFirmwareVersion: \(result.description()), version: \(version as Optional), moduleVersion: \(moduleVersion)")

            context.targetDevice.ncpVersionReceived = true

            if (result == .NONE) {
                context.targetDevice.ncpVersion = version!
                context.targetDevice.ncpModuleVersion = moduleVersion!

                self.start()
            } else if (result == .NOT_SUPPORTED) {
                context.targetDevice.ncpVersion = nil
                context.targetDevice.ncpModuleVersion = nil

                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceIsSetupDone() {
        context?.targetDevice.transceiver!.sendIsDeviceSetupDone { [weak self, weak context] result, isSetupDone in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendIsDeviceSetupDone: \(result.description()), isSetupDone: \(isSetupDone as Optional)")

            if (result == .NONE) {
                context.targetDevice.isSetupDone = isSetupDone
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNeedsOTAUpdate() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().getNextBinaryURL(context.targetDevice.type!,
                currentSystemFirmwareVersion: context.targetDevice.firmwareVersion!,
                currentNcpFirmwareVersion: context.targetDevice.ncpVersion,
                currentNcpFirmwareModuleVersion: context.targetDevice.ncpModuleVersion != nil ? NSNumber(value: context.targetDevice.ncpModuleVersion!) : nil)
        { [weak self, weak context] url, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("getNextBinaryURL: \(url), error: \(error)")

            if let url = url {
                self.nextFirmwareBinaryURL = url
                self.start()
            } else if (error == nil) {
                if let filesFlashed = context.targetDevice.firmwareFilesFlashed, filesFlashed > 0 {
                    context.delegate.meshSetupDidEnterState(self, state: .FirmwareUpdateComplete)
                }
                self.stepCompleted()
                return
            } else {
                self.fail(withReason: .FailedToUpdateDeviceOS, nsError: error)
            }
        }
    }

    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.userSelectedToUpdateFirmware = update
        self.log("userSelectedToUpdateFirmware: \(update)")

        self.start()

        return nil
    }

    func prepareForTargetDeviceReboot() {
        context?.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendSetStartupMode: \(result.description())")

            self.preparedForReboot = true

            if (result == .NONE) {
                self.start()
            } else if (result == .NOT_SUPPORTED) {
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func prepareOTABinary() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().getNextBinary(nextFirmwareBinaryURL!)
        { [weak self, weak context] url, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("prepareOTABinary: \(url), error: \(error)")

            guard error == nil else {
                self.fail(withReason: .UnableToDownloadFirmwareBinary, nsError: error)
                return
            }

            if let url = url {
                self.nextFirmwareBinaryFilePath = url
            }
            self.start()
        }
    }

    private func startFirmwareUpdate() {
        guard let context = self.context else {
            return
        }

        self.log("Starting firmware update")

        let firmwareData = try! Data(contentsOf: URL(string: nextFirmwareBinaryFilePath!)!)

        context.targetDevice.firmwareUpdateProgress = 0
        context.delegate.meshSetupDidEnterState(self, state: .FirmwareUpdateProgress)

        self.firmwareData = firmwareData

        context.targetDevice.transceiver!.sendStartFirmwareUpdate(binarySize: firmwareData.count) { [weak self, weak context] result, chunkSize in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStartFirmwareUpdate: \(result.description()), chunkSize: \(chunkSize)")

            if (result == .NONE) {
                self.chunkSize = Int(chunkSize)
                self.chunkIdx = 0

                if (context.targetDevice.firmwareFilesFlashed == nil) {
                    context.targetDevice.firmwareFilesFlashed = 0
                }

                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func sendFirmwareUpdateChunk() {
        guard let context = self.context else {
            return
        }

        guard let chunkSize = chunkSize, let chunkIdx = chunkIdx, let firmwareData = firmwareData else {
            fatalError("if we reach this point and any of firmware flash data is nil, something is wrong")
            return
        }

        let start = chunkIdx * chunkSize
        let bytesLeft = firmwareData.count - start

        context.targetDevice.firmwareUpdateProgress = 100.0 * (Double(start) / Double(firmwareData.count))
        context.delegate.meshSetupDidEnterState(self, state: .FirmwareUpdateProgress)

        self.log("bytesLeft: \(bytesLeft)")

        let subdata = firmwareData.subdata(in: start ..< min(start+chunkSize, start+bytesLeft))
        context.targetDevice.transceiver!.sendFirmwareUpdateData(data: subdata) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendFirmwareUpdateData: \(result.description())")

            if (result == .NONE) {
                self.chunkIdx! += 1

                if (self.isFileFullyFlashed()) {
                    context.targetDevice.firmwareFilesFlashed! += 1
                    context.delegate.meshSetupDidEnterState(self, state: .FirmwareUpdateFileComplete)
                }

                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func finishFirmwareUpdate() {
        context?.targetDevice.transceiver!.sendFinishFirmwareUpdate(validateOnly: false) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendFinishFirmwareUpdate: \(result.description())")

            if (result == .NONE) {
                self.firmwareUpdateFinished = true
                self.resetFirmwareFlashFlags()
                //reconnect to device by jumping back few steps in connection dropped handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        self.log("force reconnect to device")

        if self.isFileFullyFlashed() {
            let step = context.stepDelegate.rewindTo(self, step: StepConnectToTargetDevice.self, runStep: false) as! StepConnectToTargetDevice
            step.reconnectAfterForcedReboot = true
            step.reconnectAfterForcedRebootRetry = 1
            step.start()

            return true
        } else {
            return false
        }
    }

    func isFileFullyFlashed() -> Bool {
        if let chunkSize = chunkSize, let idx = chunkIdx, let data = firmwareData, (idx * chunkSize >= data.count) {
            return true
        } else {
            return false
        }
    }

    func resetFirmwareFlashFlags() {
        guard let context = self.context else {
            return
        }

        //reset all the important flags
        context.targetDevice.firmwareVersion = nil
        context.targetDevice.ncpVersion = nil
        context.targetDevice.ncpModuleVersion = nil
        context.targetDevice.ncpVersionReceived = nil
        context.targetDevice.supportsCompressedOTAUpdate = nil
    }

}
