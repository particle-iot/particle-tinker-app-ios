//
// Created by Raimundas Sakalauskas on 11/06/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import Crashlytics

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
        CLSLogv(formattedMessage, getVaList([]))

        if let file = file {
            file.write(Data("\n\(timeFormatter.string(from: Date())): ".utf8))
            file.write(Data(formattedMessage.utf8))
        }
    }

    static func clearAllLogs() {
        let fileManager = FileManager.default

        let fileURLs = getLogURLs()
        for i in 0 ..< fileURLs.count {
            try? fileManager.removeItem(at: fileURLs[i])
        }

        if (file != nil) {
            self.startLogging()
        }
    }

    static func clearStaleLogs() {
        let fileManager = FileManager.default
        let fileURLs = getLogURLs()

        if (fileURLs.count > FILE_COUNT) {
            for i in FILE_COUNT..<fileURLs.count {
                try? fileManager.removeItem(at: fileURLs[i])
            }
        }
    }

    static func getLogs() -> [(URL, Int)] {
        let urls = getLogURLs()

        let fileManager = FileManager.default

        var output = [(URL, Int)]()

        for i in 0..<urls.count {
            let url = urls[i]
            if let optionalSize = try? FileManager.default.attributesOfItem(atPath: urls[i].path)[.size] as? Int, let size = optionalSize {
                output.append((urls[i], size/1024))
            } else {
                output.append((urls[i], 0))
            }

        }

        return output
    }

    static func getLogURLs() -> [URL] {
        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if var fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
            fileURLs = fileURLs.sorted { url, url2 in
                return url.absoluteString > url2.absoluteString
            }
            return fileURLs
        }

        return []
    }
}

class LogListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var logs : [(URL, Int)] = []

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
    }

    override func viewWillAppear(_ animated: Bool) {
        loadLogs()
    }

    private func loadLogs() {
        logs = LogList.getLogs()

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "log_cell") as! DeviceTableViewCell
        cell.deviceNameLabel.text = getCellTitle(filename: logs[indexPath.row].0.deletingPathExtension().lastPathComponent)
        if (indexPath.row == 0) {
            cell.deviceTypeLabel.text = "\(logs[indexPath.row].1) KB - Current session"
        } else {

            cell.deviceTypeLabel.text = "\(logs[indexPath.row].1) KB"
        }


        return cell
    }


    private func getCellTitle(filename: String) -> String {
        var fileNameDateFormatter = DateFormatter()
        fileNameDateFormatter.dateFormat = "yyyy-MM-dd HH-mm"

        var cellTitleDateFormatter = DateFormatter()
        cellTitleDateFormatter.dateStyle = .short
        cellTitleDateFormatter.timeStyle = .none

        var cellTitleTimeFormatter = DateFormatter()
        cellTitleTimeFormatter.dateStyle = .none
        cellTitleTimeFormatter.timeStyle = .short

        if let date = fileNameDateFormatter.date(from: filename) {
            return "\(cellTitleTimeFormatter.string(from: date)) \(cellTitleDateFormatter.string(from: date))"
        } else {
            return filename
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let avc = UIActivityViewController(activityItems: [logs[indexPath.row].0], applicationActivities: nil)
        self.present(avc, animated: true)
    }

    @IBAction func clearTapped(_ sender: Any) {
        LogList.clearAllLogs()

        loadLogs()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
