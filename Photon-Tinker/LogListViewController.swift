//
// Created by Raimundas Sakalauskas on 11/06/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class LogList {

    static func startLogging() {
        //start logging
        var df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"

        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(df.string(from: Date())).log"
        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
        freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }

    static func clearAllLogs() {
        let fileManager = FileManager.default

        let fileURLs = getLogs()
        for i in 0 ..< fileURLs.count {
            try? fileManager.removeItem(at: fileURLs[i])
        }
    }

    static func clearStaleLogs() {
        let fileManager = FileManager.default
        let fileURLs = getLogs()

        if (fileURLs.count > 3) {
            for i in 3..<fileURLs.count {
                try? fileManager.removeItem(at: fileURLs[i])
            }
        }
    }

    static func getLogs() -> [URL] {
        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if var fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
            if (fileURLs.count > 3) {
                fileURLs = fileURLs.sorted { url, url2 in
                    return url.absoluteString > url2.absoluteString
                }
            }
            return fileURLs
        }
        return []
    }
}

class LogListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var logs : [URL] = []

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
        cell.deviceNameLabel.text = logs[indexPath.row].lastPathComponent
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let avc = UIActivityViewController(activityItems: [logs[indexPath.row]], applicationActivities: nil)
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
