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

protocol MeshSetupTransceiverDelegate {
    //Optional
    func didReceiveAuthReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, deviceId: String)
    func didReceiveSetClaimCodeReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveGetSerialNumberReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, serialNumber: String)
    func didReceiveGetConnectionStatusReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, connectionStatus: CloudConnectionStatus)
    func didReceiveIsClaimedReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, isClaimed: Bool)
    func didReceiveCreateNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networkInfo: MeshSetupNetworkInfo)
    func didReceiveStartCommissionerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveStopCommissionerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveStartListeningReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveStopListeningReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveDeviceSetupDoneReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveIsDeviceSetupDoneReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, isDone: Bool)
    func didReceivePrepareJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, eui64: String, password: String)
    func didReceiveAddJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveRemoveJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveJoinNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveLeaveNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType)
    func didReceiveGetNetworkInfoReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networkInfo: MeshSetupNetworkInfo?)
    func didReceiveScanNetworksReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networks: [MeshSetupNetworkInfo])

    //Non-Optional
    func didTimeoutSendingMessage(sender: MeshSetupProtocolTransceiver)
}

extension MeshSetupProtocolTransceiver {
    func didReceiveAuthReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, deviceId: String) { fatalError("Not Implemented!") }
    func didReceiveSetClaimCodeReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveGetSerialNumberReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, serialNumber: String) { fatalError("Not Implemented!") }
    func didReceiveGetConnectionStatusReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, connectionStatus: CloudConnectionStatus)  { fatalError("Not Implemented!") }
    func didReceiveIsClaimedReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, isClaimed: Bool)  { fatalError("Not Implemented!") }
    func didReceiveCreateNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networkInfo: MeshSetupNetworkInfo) { fatalError("Not Implemented!") }
    func didReceiveStartCommissionerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveStopCommissionerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveStartListeningReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveStopListeningReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveDeviceSetupDoneReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveIsDeviceSetupDoneReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, isDone: Bool) { fatalError("Not Implemented!") }
    func didReceivePrepareJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, eui64: String, password: String) { fatalError("Not Implemented!") }
    func didReceiveAddJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveRemoveJoinerReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveJoinNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveLeaveNetworkReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType) { fatalError("Not Implemented!") }
    func didReceiveGetNetworkInfoReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networkInfo: MeshSetupNetworkInfo?) { fatalError("Not Implemented!") }
    func didReceiveScanNetworksReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networks: [MeshSetupNetworkInfo]) { fatalError("Not Implemented!") }
}

class MeshSetupProtocolTransceiver: NSObject, MeshSetupBluetoothConnectionDataDelegate {
    
    var delegate: MeshSetupTransceiverDelegate

    private var bluetoothConnection: MeshSetupBluetoothConnection
    private var encryptionManager: MeshSetupEncryptionManager

    private var requestMessageId: UInt16 = 1
    private var replyRequestTypeDict: [UInt16: ControlRequestMessageType] = [:]

    private var waitingForReply: Bool = false
    private var rxBuffer: Data = Data()
    private var txBuffer: Data!
    private var retryCount: Int = 0

    private lazy var sendTimeoutWorker: DispatchWorkItem  = DispatchWorkItem() {
        [weak self] in

        if let sSelf = self {
            sSelf.messageSendTimeout()
        }
    }


    
    required init(delegate: MeshSetupTransceiverDelegate, connection: MeshSetupBluetoothConnection) {
        self.delegate = delegate
        self.bluetoothConnection = connection
        self.encryptionManager = MeshSetupEncryptionManager(derivedSecret: bluetoothConnection.derivedSecret!)

        super.init()

        self.bluetoothConnection.dataDelegate = self // take over didReceiveData delegate
    }

    private func log(_ message: String) {
        if (MeshSetup.LogTransceiver) {
            NSLog(message)
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
        self.replyRequestTypeDict[requestMsg.id] = requestMsg.type

        self.waitingForReply = true
        self.retryCount = 0

        self.requestMessageId += 1
        if (requestMessageId >= 0xff00) {
            self.requestMessageId = 1
        }

        self.txBuffer = encryptionManager.encrypt(requestMsg)
        self.sendRequestMessage()
    }

    private func sendRequestMessage() {
        self.bluetoothConnection.send(data: txBuffer)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + MeshSetup.bluetoothSendTimeoutValue,
                execute: sendTimeoutWorker)

    }

    private func messageSendTimeout() {
        log("Transceiver did timeout")
        if (retryCount < MeshSetup.bluetoothSendTimeoutRetryCount) {
            log("Retrying")
            sendRequestMessage()
        } else {
            log("Delegate.didTimeOut")
            self.delegate.didTimeoutSendingMessage(sender: self)
        }
    }

    private func serialize(message: SwiftProtobuf.Message) -> Data? {
        guard let messageData = try? message.serializedData() else {
            fatalError("Could not serialize protobuf \(type(of: message)) message")
        }

        return messageData
    }




    //MARK: Messages
    func sendAuth(password: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AuthRequest()
        requestMsgPayload.password = password

        self.prepareRequestMessage(type: .Auth, payload: self.serialize(message: requestMsgPayload))
    }


    func sendGetDeviceId() {
        let requestMsgPayload = Particle_Ctrl_GetDeviceIdRequest()

        self.prepareRequestMessage(type: .GetDeviceId, payload: self.serialize(message: requestMsgPayload))
    }


    func sendSetClaimCode(claimCode: String) {
        var requestMsgPayload = Particle_Ctrl_SetClaimCodeRequest()
        requestMsgPayload.code = claimCode

        self.prepareRequestMessage(type: .SetClaimCode, payload: self.serialize(message: requestMsgPayload))
    }


    func sendGetSerialNumber() {
        var requestMsgPayload = Particle_Ctrl_GetSerialNumberRequest()

        self.prepareRequestMessage(type: .GetSerialNumber, payload: self.serialize(message: requestMsgPayload))
    }


    func sendGetConnectionStatus() {
        var requestMsgPayload = Particle_Ctrl_Cloud_GetConnectionStatusRequest()

        self.prepareRequestMessage(type: .GetConnectionStatus, payload: self.serialize(message: requestMsgPayload))
    }


    func sendIsClaimed() {
        let requestMsgPayload = Particle_Ctrl_IsClaimedRequest()

        self.prepareRequestMessage(type: .IsClaimed, payload: self.serialize(message: requestMsgPayload))
    }


    func sendCreateNetwork(name: String, password: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password

        self.prepareRequestMessage(type: .CreateNetwork, payload: self.serialize(message: requestMsgPayload))
    }


    func sendStartCommissioner() {
        let requestMsgPayload = Particle_Ctrl_Mesh_StartCommissionerRequest()

        self.prepareRequestMessage(type: .StartCommissioner, payload: self.serialize(message: requestMsgPayload))
    }


    func sendStopCommissioner() {
        let requestMsgPayload = Particle_Ctrl_Mesh_StopCommissionerRequest()

        self.prepareRequestMessage(type: .StopCommissioner, payload: self.serialize(message: requestMsgPayload))
    }


    func sendStarListening() {
        let requestMsgPayload = Particle_Ctrl_StartListeningModeRequest();

        self.prepareRequestMessage(type: .StartListening, payload: self.serialize(message: requestMsgPayload))
    }


    func sendStopListening() {
        let requestMsgPayload = Particle_Ctrl_StopListeningModeRequest();

        self.prepareRequestMessage(type: .StopListening, payload: self.serialize(message: requestMsgPayload))
    }


    func sendDeviceSetupDone() {
        let requestMsgPayload = Particle_Ctrl_SetDeviceSetupDoneRequest();

        self.prepareRequestMessage(type: .DeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
    }


    func sendIsDeviceSetupDone() {
        let requestMsgPayload = Particle_Ctrl_IsDeviceSetupDoneRequest();

        self.prepareRequestMessage(type: .IsDeviceSetupDone, payload: self.serialize(message: requestMsgPayload))
    }


    func sendPrepareJoiner(networkInfo: Particle_Ctrl_Mesh_NetworkInfo) {
        var requestMsgPayload = Particle_Ctrl_Mesh_PrepareJoinerRequest()
        requestMsgPayload.network = networkInfo

        self.prepareRequestMessage(type: .PrepareJoiner, payload: self.serialize(message: requestMsgPayload))
    }


    func sendAddJoiner(eui64: String, password: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AddJoinerRequest()
        requestMsgPayload.eui64 = eui64
        requestMsgPayload.password = password

        self.prepareRequestMessage(type: .AddJoiner, payload: self.serialize(message: requestMsgPayload))
    }


    func sendRemoveJoiner(eui64: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_RemoveJoinerRequest()
        requestMsgPayload.eui64 = eui64

        self.prepareRequestMessage(type: .RemoveJoiner, payload: self.serialize(message: requestMsgPayload))
    }


    func sendJoinNetwork() {
        let requestMsgPayload = Particle_Ctrl_Mesh_JoinNetworkRequest()

        self.prepareRequestMessage(type: .JoinNetwork, payload: self.serialize(message: requestMsgPayload))
    }


    func sendLeaveNetwork() {
        let requestMsgPayload = Particle_Ctrl_Mesh_LeaveNetworkRequest()

        self.prepareRequestMessage(type: .LeaveNetwork, payload: self.serialize(message: requestMsgPayload))
    }


    func sendGetNetworkInfo() {
        let requestMsgPayload = Particle_Ctrl_Mesh_GetNetworkInfoRequest()

        self.prepareRequestMessage(type: .GetNetworkInfo, payload: self.serialize(message: requestMsgPayload))
    }


    func sendScanNetworks() {
        let requestMsgPayload = Particle_Ctrl_Mesh_ScanNetworksRequest()

        self.prepareRequestMessage(type: .ScanNetworks, payload: self.serialize(message: requestMsgPayload))
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

        log("Received reply message id \(rm.id) --> Payload size: \(data.count)")
        let replyRequestType = self.replyRequestTypeDict[rm.id]!

        switch replyRequestType {
            case .Auth:
                self.delegate.didReceiveAuthReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .GetDeviceId:
                let decodedReply = try! Particle_Ctrl_GetDeviceIdReply(serializedData: data) as! Particle_Ctrl_GetDeviceIdReply
                self.delegate.didReceiveDeviceIdReply(sender: self, result:rm.result, deviceId: decodedReply.id)
                log("Received reply: \(replyRequestType)")
            case .SetClaimCode:
                self.delegate.didReceiveSetClaimCodeReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .GetSerialNumber:
                let decodedReply = try! Particle_Ctrl_GetSerialNumberReply(serializedData: data) as! Particle_Ctrl_GetSerialNumberReply
                self.delegate.didReceiveGetSerialNumberReply(sender: self, result: rm.result, serialNumber: decodedReply.serial)
                log("Received reply: \(replyRequestType)")
            case .GetConnectionStatus:
                let decodedReply = try! Particle_Ctrl_Cloud_GetConnectionStatusReply(serializedData: data) as! Particle_Ctrl_Cloud_GetConnectionStatusReply
                self.delegate.didReceiveGetConnectionStatusReply(sender: self, result: rm.result, connectionStatus: decodedReply.status)
                log("Received reply: \(replyRequestType)")
            case .IsClaimed:
                let decodedReply = try! Particle_Ctrl_IsClaimedReply(serializedData: data) as! Particle_Ctrl_IsClaimedReply
                self.delegate.didReceiveIsClaimedReply(sender: self, result: rm.result, isClaimed: decodedReply.claimed)
                log("Received reply: \(replyRequestType)")
            case .CreateNetwork:
                let decodedReply = try! Particle_Ctrl_Mesh_CreateNetworkReply(serializedData: data) as! Particle_Ctrl_Mesh_CreateNetworkReply
                self.delegate.didReceiveCreateNetworkReply(sender: self, result: rm.result, networkInfo: decodedReply.network)
                log("Received reply: \(replyRequestType)")
                log("NetworkInfo:\nName: \(decodedReply.network.name)\nXPAN ID: \(decodedReply.network.extPanID)\nPAN ID: \(decodedReply.network.panID)\nChannel: \(decodedReply.network.channel)")
            case .StartCommissioner:
                self.delegate.didReceiveStartCommissionerReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .StopCommissioner:
                self.delegate.didReceiveStopCommissionerReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .StartListening:
                self.delegate.didReceiveStartListeningReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .StopListening:
                self.delegate.didReceiveStopListeningReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .DeviceSetupDone:
                self.delegate.didReceiveDeviceSetupDoneReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .IsDeviceSetupDone:
                let decodedReply = try! Particle_Ctrl_IsDeviceSetupDoneReply(serializedData: data) as! Particle_Ctrl_IsDeviceSetupDoneReply
                self.delegate.didReceiveIsDeviceSetupDoneReply(sender: self, result: rm.result, isDone: decodedReply.done)
                log("Received reply: \(replyRequestType)")
            case .PrepareJoiner:
                let decodedReply = try! Particle_Ctrl_Mesh_PrepareJoinerReply(serializedData: data) as! Particle_Ctrl_Mesh_PrepareJoinerReply
                self.delegate.didReceivePrepareJoinerReply(sender: self, result: rm.result, eui64: decodedReply.eui64, password: decodedReply.password)
                log("Received reply: \(replyRequestType)")
            case .AddJoiner:
                self.delegate.didReceiveAddJoinerReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .RemoveJoiner:
                self.delegate.didReceiveRemoveJoinerReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .JoinNetwork:
                self.delegate.didReceiveJoinNetworkReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .LeaveNetwork:
                self.delegate.didReceiveLeaveNetworkReply(sender: self, result: rm.result)
                log("Received reply: \(replyRequestType)")
            case .GetNetworkInfo:
                let decodedReply = try! Particle_Ctrl_Mesh_GetNetworkInfoReply(serializedData: data) as! Particle_Ctrl_Mesh_GetNetworkInfoReply
                self.delegate.didReceiveGetNetworkInfoReply(sender: self, result: rm.result, networkInfo: decodedReply.network)
                log("Received reply: \(replyRequestType)")
                log("NetworkInfo:\nName: \(decodedReply.network.name)\nXPAN ID: \(decodedReply.network.extPanID)\nPAN ID: \(decodedReply.network.panID)\nChannel: \(decodedReply.network.channel)")
            case .ScanNetworks:
                let decodedReply = try! Particle_Ctrl_Mesh_ScanNetworksReply(serializedData: data) as! Particle_Ctrl_Mesh_ScanNetworksReply
                self.delegate.didReceiveScanNetworksReply(sender: self, result: rm.result, networks: decodedReply.networks)
                log("Received reply: \(replyRequestType)")
        }
    }
}
