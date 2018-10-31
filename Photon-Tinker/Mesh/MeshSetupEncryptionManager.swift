//
// Created by Raimundas Sakalauskas on 23/08/2018.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import mbedTLSWrapper

class MeshSetupEncryptionManager: NSObject {

    private var cipher:AesCcmWrapper

    private var key:Data
    private var reqNonce:Data
    private var repNonce:Data

    required init(derivedSecret: Data) {
        key = derivedSecret.subdata(in: 0..<16)
        reqNonce = derivedSecret.subdata(in: 16..<24)
        repNonce = derivedSecret.subdata(in: 24..<32)

        cipher = AesCcmWrapper(key: key)!

        super.init()
    }

    func getRequestNonce(requestId: UInt32) -> Data {
        var data = Data()

        var reqIdLe = requestId.littleEndian
        data.append(UInt8(reqIdLe & 0xff))
        data.append(UInt8((reqIdLe >> 8) & 0xff))
        data.append(UInt8((reqIdLe >> 16) & 0xff))
        data.append(UInt8((reqIdLe >> 24) & 0xff))
        data.append(reqNonce)

        return data
    }

    func getReplyNonce(requestId: UInt32) -> Data {
        var data = Data()

        var reqIdLe = requestId.littleEndian
        data.append(UInt8(reqIdLe & 0xff))
        data.append(UInt8((reqIdLe >> 8) & 0xff))
        data.append(UInt8((reqIdLe >> 16) & 0xff))
        data.append(UInt8(((reqIdLe >> 24) & 0xff) | 0x80))
        data.append(repNonce)

        return data
    }


    func encrypt(_ msg: RequestMessage) -> Data {
        var requestId = UInt32(msg.id)

        var outputData = Data()
        var dataToEncrypt = Data()

        //size - store it in output data to be used as additional data during the encryption process
        var leValue = UInt16(msg.data.count).littleEndian
        outputData.append(UnsafeBufferPointer(start: &leValue, count: 1))

        //requestId
        leValue = msg.id.littleEndian
        dataToEncrypt.append(UnsafeBufferPointer(start: &leValue, count: 1))

        //type
        leValue = msg.type.rawValue.littleEndian
        dataToEncrypt.append(UnsafeBufferPointer(start: &leValue, count: 1))

        //reserved for future use
        dataToEncrypt.append(Data(repeating: 0, count: 2))

        //payload
        dataToEncrypt.append(msg.data)

        var tag:NSData? = nil
        outputData.append(cipher.encryptData(dataToEncrypt, nonce: getRequestNonce(requestId: requestId), add: outputData, tag: &tag, tagSize: 8)!)
        outputData.append(tag as! Data)

        return outputData
    }

    //decrypt part assumes that it will decrypt
    //the reply to previously encrypted request
    func decrypt(_ data: Data, messageId: UInt16) -> ReplyMessage {
        var data = data

        //read data
        var sizeData = data.subdata(in: 0..<2)
        var size: Int16 = data.withUnsafeBytes { (pointer: UnsafePointer<Int16>) -> Int16 in
            return Int16(pointer[0])
        }
        var leSize = size.littleEndian
        data.removeSubrange(0..<2)

        //read encrypted data
        var dataToDecrypt = data.subdata(in: 0..<6+Int(size))
        data.removeSubrange(0..<6+Int(size))

        //remaining part is tag
        var tag = data

        //try to decrypt
        var replNonce = getReplyNonce(requestId: UInt32(messageId))
        var decryptedData = cipher.decryptData(dataToDecrypt, nonce: replNonce, add: sizeData, tag: tag)!

        var rm = ReplyMessage(id: 0, result: .NONE, data: Data())

        //get id
        rm.id = decryptedData.withUnsafeBytes { (pointer: UnsafePointer<UInt16>) -> UInt16 in
            return UInt16(pointer[0])
        }
        decryptedData.removeSubrange(0..<2)

        //get type
        rm.result = ControlReplyErrorType(rawValue: decryptedData.withUnsafeBytes { (pointer: UnsafePointer<Int32>) -> Int32 in
            return Int32(pointer[0])
        }) ?? ControlReplyErrorType.INVALID_UNKNOWN
        decryptedData.removeSubrange(0..<4)

        //get data
        rm.data = decryptedData

        return rm
    }
}
