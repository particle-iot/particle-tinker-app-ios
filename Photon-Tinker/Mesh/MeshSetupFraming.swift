//
//  MeshSetupFraming.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 5/1/18.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2018 Particle. All rights reserved.
//

import Foundation


public enum ControlRequestMessageType: UInt16 {
    case Auth = 1001
    case GetDeviceId = 20
    case SetClaimCode = 200
    case GetSerialNumber = 21
    case GetConnectionStatus = 300
    case IsClaimed = 201
    case CreateNetwork = 1002
    case StartCommissioner = 1003
    case StopCommissioner = 1004
    case StartListening = 70
    case StopListening = 71
    case DeviceSetupDone = 73
    case IsDeviceSetupDone = 74
    case PrepareJoiner = 1005
    case AddJoiner = 1006
    case RemoveJoiner = 1007
    case JoinNetwork = 1008
    case LeaveNetwork = 1009
    case GetNetworkInfo = 1010
    case ScanNetworks = 1011
    case GetInterfaceList = 400
    case GetInterface = 401

    case GetSystemCapabilities = 32
    case GetNcpFirmwareVersion = 31
    case GetSystemVersion = 30
    case StartFirmwareUpdate = 250
    case FinishFirmwareUpdate = 251
    case CancelFirmwareUpdate = 252
    case FirmwareUpdateData = 253





    case JoinNewWifiNetwork = 500
    case JoinKnownWifiNetwork = 501
    case GetKnownWifiNetworks = 502
    case RemoveKnownWifiNetworkNetworks = 503
    case ClearKnownWifiNetworksNetworks = 504
    case GetCurrentWifiNetwork = 505
    case ScanWifiNetworks = 506
}

public enum ControlReplyErrorType: Int32 {
    case NONE = 0
    case UNKNOWN = -100
    case BUSY = -110
    case NOT_SUPPORTED = -120
    case NOT_ALLOWED = -130
    case CANCELLED = -140
    case ABORTED = -150
    case TIMEOUT = -160
    case NOT_FOUND = -170
    case ALREADY_EXISTS = -180
    case TOO_LARGE = -190
    case LIMIT_EXCEEDED = -200
    case INVALID_STATE = -210
    case IO = -220
    case NETWORK = -230
    case PROTOCOL =  -240
    case INTERNAL = -250
    case NO_MEMORY = -260
    case INVALID_ARGUMENT = -270
    case BAD_DATA = -280
    case OUT_OF_RANGE = -290
    
    case INVALID_UNKNOWN = -9999
    
    func description() -> String {
        switch self {
            case .NONE: return "OK"
            case .INVALID_ARGUMENT: return "Invalid parameter"
            case .TIMEOUT: return "Time out"
            case .NOT_SUPPORTED: return "Request not supported by this firmware version"
            case .NOT_FOUND: return "Not found"
            case .ALREADY_EXISTS: return "Already exists"
            case .INVALID_STATE: return "Invalid state"
            case .NO_MEMORY: return "No memory"
            case .NOT_ALLOWED: return "Not allowed"
            default: return "Unknown error"
        }
    }
    
}



public struct RequestMessage {
    static let FRAME_EXTRA_BYTES: Int16 = 16

    var id: UInt16
    var type: ControlRequestMessageType
    var data: Data
}



public struct ReplyMessage {
    static let FRAME_EXTRA_BYTES: Int16 = 16

    var id: UInt16
    var result: ControlReplyErrorType
    var data: Data
}
