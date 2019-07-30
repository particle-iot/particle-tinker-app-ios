//
// Created by Raimundas Sakalauskas on 8/29/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import SwiftProtobuf
import Crashlytics

typealias MeshSetupNetworkInfo = Particle_Ctrl_Mesh_NetworkInfo
typealias MeshSetupCloudConnectionStatus = Particle_Ctrl_Cloud_ConnectionStatus
typealias MeshSetupNetworkInterfaceEntry = Particle_Ctrl_InterfaceEntry
typealias MeshSetupNetworkInterface = Particle_Ctrl_Interface
typealias MeshSetupSystemCapability = Particle_Ctrl_SystemCapabilityFlag

typealias MeshSetupNewWifiNetworkInfo = Particle_Ctrl_Wifi_ScanNetworksReply.Network
typealias MeshSetupKnownWifiNetworkInfo = Particle_Ctrl_Wifi_GetKnownNetworksReply.Network

typealias MeshSetupWifiNetworkSecurity = Particle_Ctrl_Wifi_Security
typealias MeshSetupWifiNetworkCredentialsType = Particle_Ctrl_Wifi_CredentialsType
typealias MeshSetupWifiNetworkCredentials = Particle_Ctrl_Wifi_Credentials

typealias MeshSetupNetworkInterfaceType = Particle_Ctrl_InterfaceType
typealias MeshSetupSystemFeature = Particle_Ctrl_Feature

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
        ParticleLogger.logInfo("MeshSetupTransceiverDelegate", format: message, withParameters: getVaList([]))
    }

    private func prepareRequestMessage(type: ControlRequestMessageType, payload: Data) -> (UInt16, Data) {
        let requestMsg = RequestMessage(id: self.requestMessageId, type: type, data: payload)

        // add to state machine dict to know which type of reply to deserialize
        //self.replyRequestTypeDict[requestMsg.id] = requestMsg.type

        log("Preparing message: \(self.requestMessageId), type: \(type)")
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
            log("Sending message: \(message.messageId)")
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
        if (rxBuffer.count < length + ReplyMessage.FRAME_EXTRA_BYTES) {
            return
        }

        guard let pendingMessage = self.pendingMessages.first else {
            fatalError("This can't happen!")
        }

        let rm = encryptionManager.decrypt(rxBuffer, messageId: pendingMessage.messageId)
        rxBuffer.removeAll()

        self.waitingForReply = false



        self.pendingMessages.removeFirst()
        DispatchQueue.main.async {
            pendingMessage.callback(rm)
            self.sendNextMessage()
        }
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



    func sendSetStartupMode(startInListeningMode: Bool, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_SetStartupModeRequest()
        requestMsgPayload.mode = startInListeningMode ? .listeningMode : .normalMode

        let data = self.prepareRequestMessage(type: .SetStartupMode, payload: self.serialize(message: requestMsgPayload))
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


    func sendGetConnectionStatus(callback: @escaping (ControlReplyErrorType, MeshSetupCloudConnectionStatus?) -> ()) {
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


    func sendCreateNetwork(name: String, password: String, networkId:String? = nil, callback: @escaping (ControlReplyErrorType, MeshSetupNetworkInfo?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password

        if let networkId = networkId {
            requestMsgPayload.networkID = networkId
        }

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

    func sendGetDeviceIsInListeningMode(callback: @escaping (ControlReplyErrorType, Bool?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetDeviceModeRequest();

        let data = self.prepareRequestMessage(type: .GetDeviceMode, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetDeviceModeReply(serializedData: rm.data) as! Particle_Ctrl_GetDeviceModeReply
                callback(rm.result, decodedReply.mode == .listeningMode)
            } else {
                callback(.TIMEOUT, nil)
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


    func sendSetActiveSim(useExternalSim: Bool, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Cellular_SetActiveSimRequest()
        requestMsgPayload.simType = useExternalSim ? .external : .internal

        let data = self.prepareRequestMessage(type: .SetActiveSim, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendGetActiveSim(callback: @escaping (ControlReplyErrorType, Bool?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Cellular_GetActiveSimRequest()

        let data = self.prepareRequestMessage(type: .GetActiveSim, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Cellular_GetActiveSimReply(serializedData: rm.data) as! Particle_Ctrl_Cellular_GetActiveSimReply
                callback(rm.result, decodedReply.simType == .external)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetIccid(callback: @escaping (ControlReplyErrorType, String?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_Cellular_GetIccidRequest()

        let data = self.prepareRequestMessage(type: .GetIccid, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Cellular_GetIccidReply(serializedData: rm.data) as! Particle_Ctrl_Cellular_GetIccidReply
                callback(rm.result,  decodedReply.iccid)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    //MARK: OTA
    func sendSystemReset(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_SystemResetRequest()

        let data = self.prepareRequestMessage(type: .SystemReset, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendSetFeature(feature:MeshSetupSystemFeature, enabled: Bool, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_SetFeatureRequest()
        requestMsgPayload.feature = feature
        requestMsgPayload.enabled = enabled

        let data = self.prepareRequestMessage(type: .SetFeature, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendGetFeature(feature: MeshSetupSystemFeature, callback: @escaping (ControlReplyErrorType, Bool?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_GetFeatureRequest()
        requestMsgPayload.feature = feature

        let data = self.prepareRequestMessage(type: .GetFeature, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetFeatureReply(serializedData: rm.data) as! Particle_Ctrl_GetFeatureReply
                callback(rm.result,  decodedReply.enabled)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendGetSystemCapabilities(callback: @escaping (ControlReplyErrorType, MeshSetupSystemCapability?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetSystemCapabilitiesRequest()

        let data = self.prepareRequestMessage(type: .GetSystemCapabilities, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetSystemCapabilitiesReply(serializedData: rm.data) as! Particle_Ctrl_GetSystemCapabilitiesReply
                //`flags` is an OR'ed combination of individual flags defined by `SystemCapabilityFlag`
                callback(rm.result,  MeshSetupSystemCapability(rawValue: decodedReply.flags == 0 ? 0 : 1))
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendGetNcpFirmwareVersion(callback: @escaping (ControlReplyErrorType, String?, Int?) -> ()) {
        let requestMsgPayload = Particle_Ctrl_GetNcpFirmwareVersionRequest()

        let data = self.prepareRequestMessage(type: .GetNcpFirmwareVersion, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_GetNcpFirmwareVersionReply(serializedData: rm.data) as! Particle_Ctrl_GetNcpFirmwareVersionReply
                callback(rm.result, decodedReply.version, Int(decodedReply.moduleVersion))
            } else {
                callback(.TIMEOUT, nil, nil)
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

    //MARK: Wifi
    func sendJoinNewWifiNetwork(network: MeshSetupNewWifiNetworkInfo, password: String?, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_JoinNewNetworkRequest()
        requestMsgPayload.ssid = network.ssid
//        requestMsgPayload.bssid = network.bssid
//        requestMsgPayload.security = network.security

        var credentials = MeshSetupWifiNetworkCredentials()
        if let password = password {
            credentials.type = .password
            credentials.password = password
        } else {
            credentials.type = .noCredentials
        }
        requestMsgPayload.credentials = credentials


        let data = self.prepareRequestMessage(type: .JoinNewWifiNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_JoinNewNetworkReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_JoinNewNetworkReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendJoinKnownWifiNetwork(network: MeshSetupKnownWifiNetworkInfo, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_JoinKnownNetworkRequest()
        requestMsgPayload.ssid = network.ssid

        let data = self.prepareRequestMessage(type: .JoinKnownWifiNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_JoinKnownNetworkReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_JoinKnownNetworkReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendGetKnownWifiNetworks(callback: @escaping (ControlReplyErrorType, [MeshSetupKnownWifiNetworkInfo]?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_GetKnownNetworksRequest()

        let data = self.prepareRequestMessage(type: .GetKnownWifiNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_GetKnownNetworksReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_GetKnownNetworksReply
                callback(rm.result, decodedReply.networks)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }

    func sendRemoveKnownWifiNetwork(network: MeshSetupKnownWifiNetworkInfo, callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_RemoveKnownNetworkRequest()
        requestMsgPayload.ssid = network.ssid

        let data = self.prepareRequestMessage(type: .RemoveKnownWifiNetworkNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_RemoveKnownNetworkReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_RemoveKnownNetworkReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendClearKnownWifiNetworks(callback: @escaping (ControlReplyErrorType) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_ClearKnownNetworksRequest()

        let data = self.prepareRequestMessage(type: .ClearKnownWifiNetworksNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_ClearKnownNetworksReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_ClearKnownNetworksReply
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }

    func sendGetCurrentWifiNetwork(callback: @escaping (ControlReplyErrorType, MeshSetupNewWifiNetworkInfo?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_GetCurrentNetworkRequest()

        let data = self.prepareRequestMessage(type: .GetCurrentWifiNetwork, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_GetCurrentNetworkReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_GetCurrentNetworkReply

                var network = MeshSetupNewWifiNetworkInfo()
                network.ssid = decodedReply.ssid
                network.bssid = decodedReply.bssid
                network.channel = decodedReply.channel
                network.rssi = decodedReply.rssi

                callback(rm.result, network)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendScanWifiNetworks(callback: @escaping (ControlReplyErrorType, [MeshSetupNewWifiNetworkInfo]?) -> ()) {
        var requestMsgPayload = Particle_Ctrl_Wifi_ScanNetworksRequest()

        let data = self.prepareRequestMessage(type: .ScanWifiNetworks, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                let decodedReply = try! Particle_Ctrl_Wifi_ScanNetworksReply(serializedData: rm.data) as! Particle_Ctrl_Wifi_ScanNetworksReply
                callback(rm.result, decodedReply.networks)
            } else {
                callback(.TIMEOUT, nil)
            }
        })
    }


    func sendStarNyanSignal(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_StartNyanSignalRequest();

        let data = self.prepareRequestMessage(type: .StartNyanSignal, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }


    func sendStopNyanSignal(callback: @escaping (ControlReplyErrorType) -> ()) {
        let requestMsgPayload = Particle_Ctrl_StopNyanSignalRequest();

        let data = self.prepareRequestMessage(type: .StopNyanSignal, payload: self.serialize(message: requestMsgPayload))
        self.sendRequestMessage(data: data, onReply: {
            replyMessage in
            if let rm = replyMessage {
                callback(rm.result)
            } else {
                callback(.TIMEOUT)
            }
        })
    }
}
