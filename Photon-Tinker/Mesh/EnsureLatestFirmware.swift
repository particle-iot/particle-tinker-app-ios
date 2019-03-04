//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class EnsureLatestFirmware : MeshSetupStep {

    private var chunkSize: Int?
    private var chunkIdx: Int?
    private var firmwareData: Data?


    private var preparedForReboot: Bool = false


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

        self.chunkSize = nil
        self.chunkIdx = nil
        self.firmwareData = nil
    }

    override func start() {
        if (context.targetDevice.firmwareVersion == nil) {
            self.getTargetDeviceFirmwareVersion()
        } else if (context.targetDevice.supportsCompressedOTAUpdate == nil) {
            self.checkTargetDeviceSupportsCompressedOTA()
        } else if (context.targetDevice.ncpVersionReceived == nil) {
            self.checkNcpFirmwareVersion()
        } else if (context.targetDevice.isSetupDone == nil) {
            self.checkTargetDeviceIsSetupDone()
        } else if (context.targetDevice.nextFirmwareBinaryURL == nil) {
            self.checkNeedsOTAUpdate()
        } else if (context.userSelectedToUpdateFirmware == nil) {
            self.context.delegate.meshSetupDidRequestToUpdateFirmware()
        } else if (!self.preparedForReboot) {
            self.prepareForTargetDeviceReboot()
        } else if(context.targetDevice.nextFirmwareBinaryFilePath == nil) {
            self.prepareOTABinary()
        } else if (firmwareData == nil || chunkSize == nil) {
            self.startFirmwareUpdate()
        } else if (!self.isFileFullyFlashed()) {
            self.sendFirmwareUpdateChunk()
        } else {
            self.finishFirmwareUpdate()
        }
    }

    private func getTargetDeviceFirmwareVersion() {
        context.targetDevice.transceiver!.sendGetSystemVersion { result, version in
            self.log("targetDevice.sendGetSystemVersion: \(result.description()), version: \(version as Optional)")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.context.targetDevice.firmwareVersion = version!
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceSupportsCompressedOTA() {
        context.targetDevice.transceiver!.sendGetSystemCapabilities { result, capability in
            self.log("targetDevice.sendGetSystemCapabilities: \(result.description()), capability: \(capability?.rawValue as Optional)")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.context.targetDevice.supportsCompressedOTAUpdate = (capability! == MeshSetupSystemCapability.compressedOta)
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNcpFirmwareVersion() {
        context.targetDevice.transceiver!.sendGetNcpFirmwareVersion { result, version, moduleVersion in
            self.log("targetDevice.sendGetNcpFirmwareVersion: \(result.description()), version: \(version as Optional), moduleVersion: \(moduleVersion)")
            if (self.context.canceled) {
                return
            }
            self.context.targetDevice.ncpVersionReceived = true

            if (result == .NONE) {
                self.context.targetDevice.ncpVersion = version!
                self.context.targetDevice.ncpModuleVersion = moduleVersion!

                self.start()
            } else if (result == .NOT_SUPPORTED) {
                self.context.targetDevice.ncpVersion = nil
                self.context.targetDevice.ncpModuleVersion = nil

                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceIsSetupDone() {
        context.targetDevice.transceiver!.sendIsDeviceSetupDone { result, isSetupDone in
            self.log("targetDevice.sendIsDeviceSetupDone: \(result.description()), isSetupDone: \(isSetupDone as Optional)")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.context.targetDevice.isSetupDone = isSetupDone
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNeedsOTAUpdate() {
        ParticleCloud.sharedInstance().getNextBinaryURL(context.targetDevice.type!,
                currentSystemFirmwareVersion: context.targetDevice.firmwareVersion!,
                currentNcpFirmwareVersion: context.targetDevice.ncpVersion,
                currentNcpFirmwareModuleVersion: context.targetDevice.ncpModuleVersion != nil ? NSNumber(value: context.targetDevice.ncpModuleVersion!) : nil)
        { url, error in
            if (self.context.canceled) {
                return
            }

            self.log("getNextBinaryURL: \(url), error: \(error)")
            if let url = url {
                self.context.targetDevice.nextFirmwareBinaryURL = url
                self.start()
            } else if (error == nil) {
                if let filesFlashed = self.context.targetDevice.firmwareFilesFlashed, filesFlashed > 0 {
                    self.context.delegate.meshSetupDidEnterState(state: .FirmwareUpdateComplete)
                }
                self.stepCompleted()
                return
            } else {
                self.fail(withReason: .FailedToUpdateDeviceOS, nsError: error)
            }
        }
    }

    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
        self.context.userSelectedToUpdateFirmware = update
        self.log("userSelectedToUpdateFirmware: \(update)")

        self.start()

        return nil
    }

    func prepareForTargetDeviceReboot() {
        context.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { result in
            self.log("targetDevice.sendSetStartupMode: \(result.description())")
            if (self.context.canceled) {
                return
            }

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
        ParticleCloud.sharedInstance().getNextBinary(self.context.targetDevice.nextFirmwareBinaryURL!)
        { url, error in
            if (self.context.canceled) {
                return
            }

            self.log("prepareOTABinary: \(url), error: \(error)")

            guard error == nil else {
                self.fail(withReason: .UnableToDownloadFirmwareBinary, nsError: error)
                return
            }

            if let url = url {
                self.context.targetDevice.nextFirmwareBinaryFilePath = url
            }
            self.start()
        }
    }

    private func startFirmwareUpdate() {
        self.log("Starting firmware update")

        let firmwareData = try! Data(contentsOf: URL(string: self.context.targetDevice.nextFirmwareBinaryFilePath!)!)

        self.context.targetDevice.firmwareUpdateProgress = 0
        self.context.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)

        self.firmwareData = firmwareData

        self.context.targetDevice.transceiver!.sendStartFirmwareUpdate(binarySize: firmwareData.count) { result, chunkSize in
            self.log("targetDevice.sendStartFirmwareUpdate: \(result.description()), chunkSize: \(chunkSize)")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.chunkSize = Int(chunkSize)
                self.chunkIdx = 0

                if (self.context.targetDevice.firmwareFilesFlashed == nil) {
                    self.context.targetDevice.firmwareFilesFlashed = 0
                }

                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func sendFirmwareUpdateChunk() {
        guard let chunkSize = chunkSize, let chunkIdx = chunkIdx, let firmwareData = firmwareData else {
            fatalError("if we reach this point and any of firmware flash data is nil, something is wrong")
            return
        }

        let start = chunkIdx * chunkSize
        let bytesLeft = firmwareData.count - start

        self.context.targetDevice.firmwareUpdateProgress = 100.0 * (Double(start) / Double(firmwareData.count))
        self.context.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)

        self.log("bytesLeft: \(bytesLeft)")

        let subdata = firmwareData.subdata(in: start ..< min(start+chunkSize, start+bytesLeft))
        self.context.targetDevice.transceiver!.sendFirmwareUpdateData(data: subdata) { result in
            self.log("targetDevice.sendFirmwareUpdateData: \(result.description())")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                if (self.isFileFullyFlashed()) {
                    self.context.targetDevice.firmwareFilesFlashed! += 1
                    self.context.delegate.meshSetupDidEnterState(state: .FirmwareUpdateFileComplete)
                } else {
                    self.chunkIdx! += 1
                }
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func finishFirmwareUpdate() {
        self.context.targetDevice.transceiver!.sendFinishFirmwareUpdate(validateOnly: false) { result in
            self.log("targetDevice.sendFinishFirmwareUpdate: \(result.description())")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.resetFirmwareFlashFlags()
                //reconnect to device by jumping back few steps in connection dropped handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        self.log("force reconnect to device")

        if self.isFileFullyFlashed() {
            let step = self.stepDelegate.rewindTo(self, step: ConnectToTargetDevice.self) as! ConnectToTargetDevice
            step.reconnectAfterForcedReboot = true
            step.reconnectAfterForcedRebootRetry = 1

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
        //reset all the important flags
        self.context.targetDevice.firmwareVersion = nil
        self.context.targetDevice.ncpVersion = nil
        self.context.targetDevice.ncpModuleVersion = nil
        self.context.targetDevice.ncpVersionReceived = nil
        self.context.targetDevice.supportsCompressedOTAUpdate = nil
        self.context.targetDevice.nextFirmwareBinaryURL = nil
        self.context.targetDevice.nextFirmwareBinaryFilePath = nil
    }

}
