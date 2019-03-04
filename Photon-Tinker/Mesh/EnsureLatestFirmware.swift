//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class EnsureLatestFirmware : MeshSetupStep {

    private var chunkSize: Int?
    private var idx: Int?
    private var firmwareData: Data?

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
//    //MARK: EnsureLatestFirmware
//    private func stepEnsureLatestFirmware() {
//
//
//        if (self.targetDevice.firmwareVersion != nil) {
//            self.checkTargetDeviceSupportsCompressedOTA()
//            return
//        }
//
//        self.targetDevice.transceiver!.sendGetSystemVersion { result, version in
//            self.log("targetDevice.sendGetSystemVersion: \(result.description()), version: \(version as Optional)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.targetDevice.firmwareVersion = version!
//                self.checkTargetDeviceSupportsCompressedOTA()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//
//    private func checkTargetDeviceSupportsCompressedOTA() {
//        if (self.targetDevice.supportsCompressedOTAUpdate != nil) {
//            self.checkNcpFirmwareVersion()
//            return
//        }
//
//        self.targetDevice.transceiver!.sendGetSystemCapabilities { result, capability in
//            self.log("targetDevice.sendGetSystemCapabilities: \(result.description()), capability: \(capability?.rawValue as Optional)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.targetDevice.supportsCompressedOTAUpdate = (capability! == MeshSetupSystemCapability.compressedOta)
//                self.checkNcpFirmwareVersion()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func checkNcpFirmwareVersion() {
//        if (self.targetDevice.ncpVersion != nil && self.targetDevice.ncpModuleVersion != nil) {
//            self.checkTargetDeviceIsSetupDone()
//            return
//        }
//
//        self.targetDevice.transceiver!.sendGetNcpFirmwareVersion { result, version, moduleVersion in
//            self.log("targetDevice.sendGetNcpFirmwareVersion: \(result.description()), version: \(version as Optional), moduleVersion: \(moduleVersion)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.targetDevice.ncpVersion = version!
//                self.targetDevice.ncpModuleVersion = moduleVersion!
//
//                self.checkTargetDeviceIsSetupDone()
//            } else if (result == .NOT_SUPPORTED) {
//                self.targetDevice.ncpVersion = nil
//                self.targetDevice.ncpModuleVersion = nil
//
//                self.checkTargetDeviceIsSetupDone()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func checkTargetDeviceIsSetupDone() {
//        //if this has already been checked for this device
//        if (self.targetDevice.isSetupDone != nil) {
//            self.checkNeedsOTAUpdate()
//            return
//        }
//
//        self.targetDevice.transceiver!.sendIsDeviceSetupDone { result, isSetupDone in
//            self.log("targetDevice.sendIsDeviceSetupDone: \(result.description()), isSetupDone: \(isSetupDone as Optional)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.targetDevice.isSetupDone = isSetupDone
//                self.checkNeedsOTAUpdate()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func checkNeedsOTAUpdate() {
//        if (self.targetDevice.nextFirmwareBinaryURL != nil) {
//            self.binaryURLReady()
//            return
//        }
//
//
//        ParticleCloud.sharedInstance().getNextBinaryURL(targetDevice.type!,
//                currentSystemFirmwareVersion: targetDevice.firmwareVersion!,
//                currentNcpFirmwareVersion: targetDevice.ncpVersion,
//                currentNcpFirmwareModuleVersion: targetDevice.ncpModuleVersion != nil ? NSNumber(value: targetDevice.ncpModuleVersion!) : nil)
//        { url, error in
//            if (self.canceled) {
//                return
//            }
//
//            self.log("getNextBinaryURL: \(url), error: \(error)")
//            if let url = url {
//                self.targetDevice.nextFirmwareBinaryURL = url
//                self.binaryURLReady()
//            } else if (error == nil) {
//                if let filesFlashed = self.targetDevice.firmwareFilesFlashed, filesFlashed > 0 {
//                    self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateComplete)
//                }
//                self.stepComplete(.EnsureLatestFirmware)
//                return
//            } else {
//                self.fail(withReason: .FailedToUpdateDeviceOS, nsError: error)
//            }
//        }
//    }
//
//    private func binaryURLReady() {
//        if (self.userSelectedToUpdateFirmware == nil) {
//            self.delegate.meshSetupDidRequestToUpdateFirmware()
//        } else {
//            self.setTargetPerformFirmwareUpdate(update: self.userSelectedToUpdateFirmware!)
//        }
//    }
//
//    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
//        guard currentCommand == .EnsureLatestFirmware else {
//            return .IllegalOperation
//        }
//
//        self.userSelectedToUpdateFirmware = update
//        self.log("userSelectedToUpdateFirmware: \(update)")
//
//        self.prepareForTargetDeviceReboot {
//            self.prepareOTABinary()
//        }
//
//        return nil
//    }
//
//    private func prepareOTABinary() {
//        if (self.targetDevice.nextFirmwareBinaryURL == nil){
//            self.stepComplete(.EnsureLatestFirmware)
//            return
//        }
//
//
//        if (self.targetDevice.nextFirmwareBinaryFilePath != nil) {
//            self.startFirmwareUpdate()
//            return
//        }
//
//        ParticleCloud.sharedInstance().getNextBinary(self.targetDevice.nextFirmwareBinaryURL!)
//        { url, error in
//            if (self.canceled) {
//                return
//            }
//
//            self.log("prepareOTABinary: \(url), error: \(error)")
//
//            guard error == nil else {
//                self.fail(withReason: .UnableToDownloadFirmwareBinary, nsError: error)
//                return
//            }
//
//            if let url = url {
//                self.targetDevice.nextFirmwareBinaryFilePath = url
//                self.startFirmwareUpdate()
//            }
//        }
//    }
//
//    private func startFirmwareUpdate() {
//        self.log("Starting firmware update")
//
//        let firmwareData = try! Data(contentsOf: URL(string: self.targetDevice.nextFirmwareBinaryFilePath!)!)
//
//        self.targetDevice.firmwareUpdateProgress = 0
//        self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)
//
//        self.currentStepFlags["firmwareData"] = firmwareData
//        self.targetDevice.transceiver!.sendStartFirmwareUpdate(binarySize: firmwareData.count) { result, chunkSize in
//            self.log("targetDevice.sendStartFirmwareUpdate: \(result.description()), chunkSize: \(chunkSize)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.currentStepFlags["chunkSize"] = Int(chunkSize)
//                self.currentStepFlags["idx"] = 0
//
//                if (self.targetDevice.firmwareFilesFlashed == nil) {
//                    self.targetDevice.firmwareFilesFlashed = 0
//                }
//
//                self.sendFirmwareUpdateChunk()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func sendFirmwareUpdateChunk() {
//        let chunk = self.currentStepFlags["chunkSize"] as! Int
//        let idx = self.currentStepFlags["idx"] as! Int
//        let firmwareData = self.currentStepFlags["firmwareData"] as! Data
//
//        let start = idx*chunk
//        let bytesLeft = firmwareData.count - start
//
//
//        self.targetDevice.firmwareUpdateProgress = 100.0 * (Double(start) / Double(firmwareData.count))
//        self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)
//
//        self.log("bytesLeft: \(bytesLeft)")
//
//        let subdata = firmwareData.subdata(in: start ..< min(start+chunk, start+bytesLeft))
//        self.targetDevice.transceiver!.sendFirmwareUpdateData(data: subdata) { result in
//            self.log("targetDevice.sendFirmwareUpdateData: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                if ((idx+1) * chunk >= firmwareData.count) {
//                    self.finishFirmwareUpdate()
//                    self.targetDevice.firmwareFilesFlashed! += 1
//                    self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateFileComplete)
//                } else {
//                    self.currentStepFlags["idx"] = idx + 1
//                    self.sendFirmwareUpdateChunk()
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func finishFirmwareUpdate() {
//        self.targetDevice.transceiver!.sendFinishFirmwareUpdate(validateOnly: false) { result in
//            self.log("targetDevice.sendFinishFirmwareUpdate: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.resetFirmwareFlashFlags()
//                //reconnect to device by jumping back few steps in connection dropped handler
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        self.log("force reconnect to device")

        if let chunk = chunkSize,
            let idx = idx,
            let data = firmwareData,
            ((idx+1) * chunk >= data.count) {

            let step = self.stepDelegate.rewindTo(self, step: ConnectToTargetDevice.self) as! ConnectToTargetDevice
            step.reconnectAfterForcedReboot = true
            step.reconnectAfterForcedRebootRetry = 1

            return true
        } else {
            return false
        }
    }

}
