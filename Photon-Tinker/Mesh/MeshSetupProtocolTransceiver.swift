//
// Created by Raimundas Sakalauskas on 8/29/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import SwiftProtobuf

typealias MeshSetupNetworkInfo = Particle_Ctrl_Mesh_NetworkInfo
typealias CloudConnectionStatus = Particle_Ctrl_Cloud_ConnectionStatus
typealias MeshSetupNetworkInterfaceEntry = Particle_Ctrl_InterfaceEntry
typealias MeshSetupNetworkInterface = Particle_Ctrl_Interface
typealias SystemCapability = Particle_Ctrl_SystemCapabilityFlag

class MeshSetupProtocolTransceiver: NSObject, MeshSetupBluetoothConnectionDataDelegate {

    private struct PendingMessage {
        var messageId: UInt16
        var data: Data
        var writeWithResponse: Bool
        var callback: (ReplyMessage?) -> ()
    }

    var isBusy: Bool {
        get {
            return waitingForReply
        }
    }

    private var bluetoothConnection: MeshSetupBluetoothConnection
    private var encryptionManager: MeshSetupEncryptionManager

    private var requestMessageId: UInt16 = 1
    private var waitingForReply: Bool = false

    private var pendingMessages: [PendingMessage] = []

    private var rxBuffer: Data = Data()


    var connection: MeshSetupBluetoothConnection {
        get {
            return bluetoothConnection
        }
    }

    func triggerTimeout() {
        if let callback = pendingMessages.first?.callback {

            //to avoid message idx getting out of sync with device
            requestMessageId = requestMessageId - UInt16(pendingMessages.count)

            pendingMessages.removeAll()
            waitingForReply = false
            callback(nil)
        }
    }


    required init(connection: MeshSetupBluetoothConnection) {
        self.bluetoothConnection = connection
        self.encryptionManager = MeshSetupEncryptionManager(derivedSecret: bluetoothConnection.derivedSecret!)

        super.init()

        self.bluetoothConnection.dataDelegate = self // take over didReceiveData delegate
    }

    private func log(_ message: String) {
        if (MeshSetup.LogTransceiver) {
            NSLog("MeshSetupTransceiverDelegate: \(message)")
        }
    }

    private func prepareRequestMessage(type: ControlRequestMessageType, payload: Data) -> (UInt16, Data) {
        let requestMsg = RequestMessage(id: self.requestMessageId, type: type, data: payload)

        // add to state machine dict to know which type of reply to deserialize
        //self.replyRequestTypeDict[requestMsg.id] = requestMsg.type

        let response = (self.requestMessageId, encryptionManager.encrypt(requestMsg))

        self.requestMessageId += 1
        if (requestMessageId >= 0xff00) {
            self.requestMessageId = 1
        }

        return response
    }

    private func sendRequestMessage(data: (UInt16, Data), onReply: @escaping (ReplyMessage?) -> ()) {
        if (self.bluetoothConnection.cbPeripheral.state == .disconnected || self.bluetoothConnection.cbPeripheral.state == .disconnecting) {
            self.requestMessageId -= 1 //to avoid message idx getting out of sync with device
            onReply(nil)
            return
        }

        self.pendingMessages.append(PendingMessage(messageId: data.0, data: data.1, writeWithResponse: true, callback: onReply))
        self.sendNextMessage()
    }

    private func sendOTARequestMessage(data: (UInt16, Data), onReply: @escaping (ReplyMessage?) -> ()) {
        if (self.bluetoothConnection.cbPeripheral.state == .disconnected || self.bluetoothConnection.cbPeripheral.state == .disconnecting) {
            self.requestMessageId -= 1 //to avoid message idx getting out of sync with device
            onReply(nil)
            return
        }

        self.pendingMessages.append(PendingMessage(messageId: data.0, data: data.1, writeWithResponse: false, callback: onReply))
        self.sendNextMessage()
    }

    private func sendNextMessage() {
        if self.pendingMessages.count > 0, self.waitingForReply == false {
            self.waitingForReply = true
            let message = self.pendingMessages.first!
            self.bluetoothConnection.send(data: message.data, writeType: message.writeWithResponse ? .withResponse : .withoutResponse)
        }
    }


    private func serialize(message: SwiftProtobuf.Message) -> Data {
        guard let messageData = try? message.serializedData() else {
            fatalError("Could not serialize protobuf \(type(of: message)) message")
        }

        return messageData
    }

    //MARK: MeshSetupBluetoothConnectionDataDelegate
    func bluetoothConnectionDidReceiveData(sender: MeshSetupBluetoothConnection, data: Data) {
        rxBuffer.append(contentsOf: data)

        //if received data is less than handshake data header length
        if (rxBuffer.count < 2) {
            return
        }

        //read the length of the message
        var length: Int16 = rxBuffer.withUnsafeBytes { (pointer: UnsafePointer<Int16>) -> Int16 in
            return Int16(pointer[0])
        }

        //we didn't receive the full message yet.
        if (rxBuffer.count < length + 16) {
            return
        }

        guard let pendingMessage = self.pendingMessages.first else {
            fatalError("This can't happen!")
        }

        let rm = encryptionManager.decrypt(rxBuffer, messageId: pendingMessage.messageId)
        rxBuffer.removeAll()

        self.waitingForReply = false



        self.pendingMessages.removeFirst()
        pendingMessage.callback(rm)
        self.sendNextMessage()
    }



    //MARK: Messages
    func sendAuth(password: String, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AuthRequest()
        requestMsgPayload.password = password

        let data = self.prepareRequestMessage(type: .Auth, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendGetDeviceId(callback: @escaping (ControlReplyErrorType, String?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetDeviceIdRequest()

        let data = self.prepareRequestMessage(type: .GetDeviceId, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetDeviceIdReply(serializedData: rm.data) as! Particle_Ctrl_GetDeviceIdReply
                callback(rm.result, decodedReply.id)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendSetClaimCode(claimCode: String, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_SetClaimCodeRequest()
        requestMsgPayload.code = claimCode

        let data = self.prepareRequestMessage(type: .SetClaimCode, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendGetSerialNumber(callback: @escaping (ControlReplyErrorType, String?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_GetSerialNumberRequest()

        let data = self.prepareRequestMessage(type: .GetSerialNumber, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetSerialNumberReply(serializedData: rm.data) as! Particle_Ctrl_GetSerialNumberReply
                callback(rm.result, decodedReply.serial)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendGetConnectionStatus(callback: @escaping (ControlReplyErrorType, CloudConnectionStatus?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Cloud_GetConnectionStatusRequest()

        let data = self.prepareRequestMessage(type: .GetConnectionStatus, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Cloud_GetConnectionStatusReply(serializedData: rm.data) as! Particle_Ctrl_Cloud_GetConnectionStatusReply
                callback(rm.result, decodedReply.status)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendIsClaimed(callback: @escaping (ControlReplyErrorType, Bool?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_IsClaimedRequest()

        let data = self.prepareRequestMessage(type: .IsClaimed, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_IsClaimedReply(serializedData: rm.data) as! Particle_Ctrl_IsClaimedReply
                callback(rm.result, decodedReply.claimed)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendCreateNetwork(name: String, password: String, callback: @escaping (ControlReplyErrorType, MeshSetupNetworkInfo?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password

        let data = self.prepareRequestMessage(type: .CreateNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Mesh_CreateNetworkReply(serializedData: rm.data) as! Particle_Ctrl_Mesh_CreateNetworkReply
                callback(rm.result, decodedReply.network)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendStartCommissioner(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_StartCommissionerRequest()

        let data = self.prepareRequestMessage(type: .StartCommissioner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendStopCommissioner(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_StopCommissionerRequest()

        let data = self.prepareRequestMessage(type: .StopCommissioner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendStarListening(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_StartListeningModeRequest();

        let data = self.prepareRequestMessage(type: .StartListening, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendStopListening(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_StopListeningModeRequest();

        let data = self.prepareRequestMessage(type: .StopListening, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendDeviceSetupDone(done: Bool, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_SetDeviceSetupDoneRequest();
        requestMsgPayload.done = done

        let data = self.prepareRequestMessage(type: .DeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    //No documented errors
    func sendIsDeviceSetupDone(callback: @escaping (ControlReplyErrorType, Bool?) -> Void) {
        let requestMsgPayload = Particle_Ctrl_IsDeviceSetupDoneRequest();

        let data = self.prepareRequestMessage(type: .IsDeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_IsDeviceSetupDoneReply(serializedData: rm.data) as! Particle_Ctrl_IsDeviceSetupDoneReply
                callback(rm.result, decodedReply.done)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    //result eui64, password
    func sendPrepareJoiner(networkInfo: MeshSetupNetworkInfo, callback: @escaping (ControlReplyErrorType, String?, String?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_PrepareJoinerRequest()
        requestMsgPayload.network = networkInfo

        let data = self.prepareRequestMessage(type: .PrepareJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Mesh_PrepareJoinerReply(serializedData: rm.data) as! Particle_Ctrl_Mesh_PrepareJoinerReply
                callback(rm.result, decodedReply.eui64, decodedReply.password)
            } else {
                callback(.TIMEOUT, nil, nil)
            }
        })
    }


    func sendAddJoiner(eui64: String, password: String, callback: @escaping (_ result: ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AddJoinerRequest()
        requestMsgPayload.eui64 = eui64
        requestMsgPayload.password = password

        let data = self.prepareRequestMessage(type: .AddJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendRemoveJoiner(eui64: String, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_RemoveJoinerRequest()
        requestMsgPayload.eui64 = eui64

        let data = self.prepareRequestMessage(type: .RemoveJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendJoinNetwork(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_JoinNetworkRequest()

        let data = self.prepareRequestMessage(type: .JoinNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendLeaveNetwork(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_LeaveNetworkRequest()

        let data = self.prepareRequestMessage(type: .LeaveNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendGetNetworkInfo(callback: @escaping (ControlReplyErrorType, MeshSetupNetworkInfo?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_GetNetworkInfoRequest()

        let data = self.prepareRequestMessage(type: .GetNetworkInfo, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Mesh_GetNetworkInfoReply(serializedData: rm.data) as! Particle_Ctrl_Mesh_GetNetworkInfoReply
                callback(rm.result, decodedReply.network)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendScanNetworks(callback: @escaping (ControlReplyErrorType, [MeshSetupNetworkInfo]?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Mesh_ScanNetworksRequest()

        let data = self.prepareRequestMessage(type: .ScanNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Mesh_ScanNetworksReply(serializedData: rm.data) as! Particle_Ctrl_Mesh_ScanNetworksReply
                callback(rm.result, decodedReply.networks)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetInterfaceList(callback: @escaping (ControlReplyErrorType, [MeshSetupNetworkInterfaceEntry]?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetInterfaceListRequest()

        let data = self.prepareRequestMessage(type: .GetInterfaceList, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetInterfaceListReply(serializedData: rm.data) as! Particle_Ctrl_GetInterfaceListReply
                callback(rm.result, decodedReply.interfaces)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetInterface(interfaceIndex: UInt32, callback: @escaping (ControlReplyErrorType, MeshSetupNetworkInterface?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_GetInterfaceRequest()
        requestMsgPayload.index = interfaceIndex

        let data = self.prepareRequestMessage(type: .GetInterface, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetInterfaceReply(serializedData: rm.data) as! Particle_Ctrl_GetInterfaceReply
                callback(rm.result, decodedReply.interface)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetSystemCapabilities(callback: @escaping (ControlReplyErrorType, SystemCapability?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetSystemCapabilitiesRequest()

        let data = self.prepareRequestMessage(type: .GetSystemCapabilities, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetSystemCapabilitiesReply(serializedData: rm.data) as! Particle_Ctrl_GetSystemCapabilitiesReply
                //`flags` is an OR'ed combination of individual flags defined by `SystemCapabilityFlag`
                callback(rm.result,  SystemCapability(rawValue: decodedReply.flags == 0 ? 0 : 1))
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetSystemVersion(callback: @escaping (ControlReplyErrorType, String?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetSystemVersionRequest()

        let data = self.prepareRequestMessage(type: .GetSystemVersion, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetSystemVersionReply(serializedData: rm.data) as! Particle_Ctrl_GetSystemVersionReply
                callback(rm.result, decodedReply.version)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendStartFirmwareUpdate(binarySize: Int, callback: @escaping (ControlReplyErrorType, UInt32) -> ()) {
        var requestMsgPayload = Particle_Ctrl_StartFirmwareUpdateRequest()
        requestMsgPayload.format = .bin
        requestMsgPayload.size = UInt32(binarySize)

        let data = self.prepareRequestMessage(type: .StartFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_StartFirmwareUpdateReply(serializedData: rm.data) as! Particle_Ctrl_StartFirmwareUpdateReply
                callback(rm.result, decodedReply.chunkSize)
            } else {
                callback(.TIMEOUT, 0)
            }
        })
    }

    func sendFinishFirmwareUpdate(validateOnly: Bool, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_FinishFirmwareUpdateRequest()
        requestMsgPayload.validateOnly = validateOnly

        let data = self.prepareRequestMessage(type: .FinishFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_FinishFirmwareUpdateReply(serializedData: rm.data) as! Particle_Ctrl_FinishFirmwareUpdateReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendCancelFirmwareUpdate(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_CancelFirmwareUpdateRequest()

        let data = self.prepareRequestMessage(type: .CancelFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_CancelFirmwareUpdateReply(serializedData: rm.data) as! Particle_Ctrl_CancelFirmwareUpdateReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendFirmwareUpdateData(data: Data, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_FirmwareUpdateDataRequest()
        requestMsgPayload.data = data

        let data = self.prepareRequestMessage(type: .FirmwareUpdateData, payload: self.serialize(message: requestMsgPayload))
        self.sendOTARequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_FirmwareUpdateDataReply(serializedData: rm.data) as! Particle_Ctrl_FirmwareUpdateDataReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }
}