//
//  MeshSetupProtocolTransceiver.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/18.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import SwiftProtobuf

typealias MeshSetupNetworkInfo = Particle_Ctrl_Mesh_NetworkInfo
typealias CloudConnectionStatus = Particle_Ctrl_Cloud_ConnectionStatus
typealias MeshSetupNetworkInterfaceEntry = Particle_Ctrl_InterfaceEntry
typealias MeshSetupNetworkInterface = Particle_Ctrl_Interface
typealias SystemCapability = Particle_Ctrl_SystemCapabilityFlag

class MeshSetupProtocolTransceiver: NSObject, MeshSetupBluetoothConnectionDataDelegate {

    private var bluetoothConnection: MeshSetupBluetoothConnection
    private var encryptionManager: MeshSetupEncryptionManager

    private var requestMessageId: UInt16 = 1

    private var waitingForReply: Bool = false
    private var rxBuffer: Data = Data()
    private var txBuffer: Data!

    private var onReplyCallback: ((ReplyMessage?) -> ())!

    var connection: MeshSetupBluetoothConnection {
        get {
            return bluetoothConnection
        }
    }

    private lazy var sendTimeoutWorker: DispatchWorkItem  = DispatchWorkItem() {
        [weak self] in

        NSLog("what is happening?")

        if let sSelf = self {
            sSelf.messageSendTimeout()
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





    private func prepareRequestMessage(type: ControlRequestMessageType, payload: Data) {
        if self.waitingForReply {
            fatalError("Trying to send message while transceiver is waiting for a reply")
        }

        NSLog("Sending message: \(type)")
        let requestMsg = RequestMessage(id: self.requestMessageId, type: type, data: payload)

        //encrypt
        self.encryptionManager.encrypt(requestMsg)

        // add to state machine dict to know which type of reply to deserialize
        //self.replyRequestTypeDict[requestMsg.id] = requestMsg.type

        self.waitingForReply = true

        self.requestMessageId += 1
        if (requestMessageId >= 0xff00) {
            self.requestMessageId = 1
        }

        self.txBuffer = encryptionManager.encrypt(requestMsg)
    }

    private func sendRequestMessage(onReply: @escaping (ReplyMessage?) -> ()) {
        self.onReplyCallback = onReply

        self.bluetoothConnection.send(data: txBuffer)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + MeshSetup.bluetoothSendTimeoutValue,
                execute: sendTimeoutWorker)
    }

    private func messageSendTimeout() {
        self.onReplyCallback(nil)
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
        self.sendTimeoutWorker.cancel()

        //if received data is less than handshake data header length
        if (rxBuffer.count < 2) {
            return
        }

        //read the length of the message
        var length: Int16 = rxBuffer.withUnsafeBytes { (pointer: UnsafePointer<Int16>) -> Int16 in
            return Int16(pointer[0])
        }

        //if we don't have enough data, reschedule timeout timer
        if (rxBuffer.count < Int(ReplyMessage.FRAME_EXTRA_BYTES + length)){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + MeshSetup.bluetoothSendTimeoutValue,
                    execute: sendTimeoutWorker)

            return
        }

        let rm = encryptionManager.decrypt(data)
        rxBuffer.removeAll()
        self.waitingForReply = false

        self.onReplyCallback!(rm)
    }



    //MARK: Messages
    func sendAuth(password: String, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AuthRequest()
        requestMsgPayload.password = password

        self.prepareRequestMessage(type: .Auth, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetDeviceId, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .SetClaimCode, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetSerialNumber, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetConnectionStatus, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .IsClaimed, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .CreateNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .StartCommissioner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .StopCommissioner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .StartListening, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .StopListening, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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
        requestMsgPayload.done = true

        self.prepareRequestMessage(type: .DeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .IsDeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .PrepareJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .AddJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .RemoveJoiner, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .JoinNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .LeaveNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetNetworkInfo, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .ScanNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetInterfaceList, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetInterface, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetSystemCapabilities, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .GetSystemVersion, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .StartFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .FinishFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .CancelFirmwareUpdate, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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

        self.prepareRequestMessage(type: .FirmwareUpdateData, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(onReply: {
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
