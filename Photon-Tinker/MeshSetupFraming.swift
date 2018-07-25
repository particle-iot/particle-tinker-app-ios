//
//  MeshSetupFraming.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 5/1/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation


public enum ControlRequestMessageType: UInt16 {
    case Auth = 1001
    case GetDeviceId = 20
    case SetClaimCode = 200
    case GetSerialNumber = 21
    case GetConnectionStatus = 300
    case IsClaimed = 201
    case SetSecurityKey = 210
    case GetSecurityKey = 211
    case CreateNetwork = 1002
    case StartCommissioner = 1003
    case StopCommissioner = 1004
    case PrepareJoiner = 1005
    case AddJoiner = 1006
    case RemoveJoiner = 1007
    case JoinNetwork = 1008
    case LeaveNetwork = 1009
    case GetNetworkInfo = 1010
    case ScanNetworks = 1011
    case Test = 1111
    
}

public enum ControlRequestErrorType : Int16 {
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
            case .NONE : return "OK"
            case .INVALID_ARGUMENT : return "Invalid parameter"
            case .TIMEOUT : return "Time out"
            case .NOT_FOUND : return "Not found"
            case .ALREADY_EXISTS : return "Already exists"
            case .INVALID_STATE : return "Invalid state"
            case .NO_MEMORY : return "No memory"
            case .NOT_ALLOWED : return "Not allowed"
            default : return "Unknown error"
        }
    }
    
}



public struct RequestMessage {
    
    var id: UInt16
    var type: ControlRequestMessageType
    var size: UInt32
    var data: Data
    
    init(id aId: UInt16, type aType: ControlRequestMessageType, size aSize: UInt32, data aData: Data) {
        self.id = aId
        self.type = aType
        self.size = aSize
        self.data = aData
    }
    
    static func serialize(requestMessage msg: RequestMessage) -> Data {
        //        var fw = w
        //        return Data(bytes: &fw, count: MemoryLayout<RequestMessage>.stride)
        var sData = Data()
        
        var leIdValue = msg.id.littleEndian
        sData.append(UnsafeBufferPointer(start: &leIdValue, count: 1))
        var leTypeValue = msg.type.rawValue.littleEndian
        sData.append(UnsafeBufferPointer(start: &leTypeValue, count: 1))
        var leSizeValue = msg.size.littleEndian
        sData.append(UnsafeBufferPointer(start: &leSizeValue, count: 1))
        
        
        msg.data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            sData.append(u8Ptr, count: msg.data.count)
        }
        
        return sData
        
    }
    
}



public struct ReplyMessage {
    
    var id: UInt16
    var result: ControlRequestErrorType
    var size: UInt32
    var data: Data?
    
    init(id aId: UInt16, result aResult: ControlRequestErrorType, size aSize: UInt32, data aData: Data?) {
        self.id = aId
        self.result = aResult
        self.size = aSize
        self.data = aData
    }
    
    static func deserialize(buffer aBuffer: Data) -> ReplyMessage {
        //        var fw = w
        //        return Data(bytes: &fw, count: MemoryLayout<RequestMessage>.stride)
        
        var rm = ReplyMessage(id: 0, result: .NONE, size: 0, data: nil)
        
        var buffer = aBuffer
        
        var bufData = buffer as NSData
        bufData.getBytes(&rm.id, length: 2)
        
        // Create a range based on the length of data to return
        var result : Int16 = 0
        
        var range = Range(0..<2)
        buffer.removeSubrange(range)
        bufData = buffer as NSData
        bufData.getBytes(&result, length: 2)
        
        if let resultEnum = ControlRequestErrorType(rawValue: result) {
            rm.result = resultEnum
        } else {
            print("Error deserializing ReplyMessage \(result) into ControlRequestErrorType")
            rm.result = .INVALID_UNKNOWN
        }
        
        
        range = Range(0..<2)
        buffer.removeSubrange(range)
        bufData = buffer as NSData
        bufData.getBytes(&rm.size, length: 4)
        
        range = Range(0..<4)
        buffer.removeSubrange(range)
        bufData = buffer as NSData
        
        //        rm.data = aBuffer.copyBytes
        //        let payloadCount = buffer.count-8
        //        var payloadArray : Array<UInt8> = [UInt8](repeating: 0, count: payloadCount)
        //        bufData.getBytes(&payloadArray, range: NSRange(location: 8, length: payloadCount))
        //        rm.data = Data(bytes: payloadArray)
        rm.data = buffer
        
        return rm
        
    }
    
}
