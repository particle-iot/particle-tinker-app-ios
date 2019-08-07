//
// Created by Raimundas Sakalauskas on 11/06/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import Crashlytics
import Zip

class LogList {

    static let FILE_COUNT = 10

    static var file: FileHandle?

    static func startLogging() {
        //start logging
        var df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH-mm"

        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(df.string(from: Date())).log"
        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)

        if (!FileManager.default.fileExists(atPath: logFilePath)) {
            FileManager.default.createFile(atPath: logFilePath, contents: Data())
        }

        if let file = FileHandle.init(forWritingAtPath: logFilePath) {
            file.seekToEndOfFile()
            self.file = file
        }

        NotificationCenter.default.removeObserver(self);
        NotificationCenter.default.addObserver(self, selector: #selector(handleLog), name: NSNotification.Name.ParticleLog, object: nil)
    }

    static var timeFormatter:DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm:ss"
        return tf
    }()

    @objc static func handleLog(notification: Notification) {
        let component = (notification.object as? String) ?? "Unknown"
        let typeInt =  notification.userInfo?[ParticleLogNotificationTypeKey] as? Int32 ?? -1
        let typeString = ParticleLogger.logTypeString(from: typeInt)
        let message = notification.userInfo?[ParticleLogNotificationMessageKey] as? String ?? ""

        var formattedMessage = "(\(component) \(typeString)) \(message)"
        #if !DEBUG
        CLSLogv(formattedMessage, getVaList([]))
        #endif

        if let file = file {
            file.write(Data("\n\(timeFormatter.string(from: Date())): ".utf8))
            file.write(Data(formattedMessage.utf8))
        }
    }

    static func clearAllLogs() {
        let fileManager = FileManager.default

        let fileURLs = getFileURLs()
        for i in 0 ..< fileURLs.count {
            try? fileManager.removeItem(at: fileURLs[i])
        }

        if (file != nil) {
            self.startLogging()
        }
    }

    static func clearStaleLogs() {
        let fileManager = FileManager.default
        let fileURLs = getFileURLs()

        if (fileURLs.count > FILE_COUNT) {
            for i in FILE_COUNT..<fileURLs.count {
                try? fileManager.removeItem(at: fileURLs[i])
            }
        }
    }

    static func clearAllZips() {
        let fileManager = FileManager.default
        let fileURLs = getFileURLs(fileExtension: "zip")

        for i in 0..<fileURLs.count {
            try? fileManager.removeItem(at: fileURLs[i])
        }
    }

    static func getFileURLs(fileExtension: String = "log") -> [URL] {
        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if var fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
            fileURLs = fileURLs.sorted { url, url2 in
                return url.absoluteString > url2.absoluteString
            }
            fileURLs = fileURLs.filter {
                (url: URL) -> Bool in url.pathExtension == fileExtension
            }
            return fileURLs
        }

        return []
    }

    static func getZip() -> URL? {
        //remove previous files if they exist
        LogList.clearAllZips()

        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HH-mm"

        let title = "\(dateFormatter.string(from: Date())) Particle app logs"
        do {
            let zipFilePath = try Zip.quickZipFiles(getFileURLs(), fileName: title)
            ParticleLogger.logInfo("LogList", format: "Zip.quickZipFiles: %@", withParameters: getVaList([zipFilePath.absoluteString]))
            return zipFilePath
        } catch {
            ParticleLogger.logError("LogList", format: "Zip.quickZipFiles error: %@", withParameters: getVaList([error.localizedDescription]))
        }

        return nil
    }


}