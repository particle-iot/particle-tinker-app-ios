//
// Created by Raimundas Sakalauskas on 2019-05-13.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorTinkerViewController: DeviceInspectorChildViewController {

    @IBOutlet var tinkerView: TinkerView!
    @IBOutlet var flashTinkerView: FlashTinkerView!
    @IBOutlet var deviceOfflineView: UIView!
    
    private var flashStarted: Bool = false

    override var isRefreshing: Bool {
        return flashStarted
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
        self.tinkerView.setup(device)
        self.flashTinkerView.setup(device)
    }

    override func setup(device: ParticleDevice) {
        super.setup(device: device)
    }
    
    

    override func update() {
        super.update()

        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

        if (self.flashStarted && self.device.isRunningTinker()) {
            self.flashStarted = false
            self.flashTinkerView.resume()
        }

        self.setupTableViewHeader()
    }

    private func setupTableViewHeader() {
        self.tableView.tableHeaderView = nil
        self.flashTinkerView.removeFromSuperview()
        self.tinkerView.removeFromSuperview()
        self.deviceOfflineView.removeFromSuperview()

        if (self.device.connected) {
            if (self.device.isRunningTinker()) {
                self.tableView.tableHeaderView = self.tinkerView
            } else {
                self.tableView.tableHeaderView = self.flashTinkerView
            }
        } else {
            self.tableView.tableHeaderView = self.deviceOfflineView
        }

        self.adjustTableViewHeaderViewConstraints()
    }

    override func showTutorial() {
        if (self.device.connected && self.device.isRunningTinker()) {
            if ParticleUtils.shouldDisplayTutorialForViewController(self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    // 2
                    var tutorial2 = YCTutorialBox(headline: "Blink the onboard LED", withHelpText: "Tap any pin to get started. Start with pin D7 - select 'digitalWrite' and tap the pin, see what happens on your device. You've just flashed an LED over the internet! Reset any pin function by long-pressing it.")

                    // 1
                    var tutorial = YCTutorialBox(headline: "Welcome to Tinker!", withHelpText: "Tinker is the fastest and easiest way to prototype and play with your Particle device. Access the basic input/output functions of the device pins without writing a line of code.") {
                        tutorial2?.showAndFocus(self.tinkerView.pinViews["D7"])
                    }
                    tutorial?.showAndFocus(self.view)

                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
            }

        }
    }

    @IBAction func flashTinkerButtonTapped(_ sender: Any) {
        self.flashTinker()
    }


    func flashTinkerBinary(_ binaryFilename : String?)
    {
        let bundle = Bundle.main
        let path = bundle.path(forResource: binaryFilename, ofType: "bin")
        let binary = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let filesDict = ["tinker.bin" : binary!]

        self.device.flashFiles(filesDict, completion: { [weak self] (error:Error?) -> Void in
            if let e=error
            {
                if let self = self {
                    DispatchQueue.main.async {
                        self.flashStarted = false
                        self.flashTinkerView.resume()

                        RMessage.showNotification(withTitle: "Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .error, customTypeName: nil, duration: -1, callback: nil)
                    }
                }
            }
        })
    }

    func flashTinker() {
        SEGAnalytics.shared().track("DeviceInspector_ReflashTinkerStart", properties: ["device":"Electron"])

        switch (self.device.type)
        {
            case .photon:
                flashTinkerBinary("photon-tinker")
            case .electron:
                flashTinkerBinary("electron-tinker")
            case .argon:
                flashTinkerBinary("tinker-0.8.0-rc.27-argon")
            case .boron:
                flashTinkerBinary("tinker-0.8.0-rc.27-boron")
            case .xenon:
                flashTinkerBinary("tinker-0.8.0-rc.27-xenon")
            default:
                RMessage.showNotification(withTitle: "Reflash Tinker", subtitle: "App does not support flashing tinker to this device.", type: .error, customTypeName: nil, duration: -1, callback: nil)
                return
        }

        self.flashStarted = true
        self.flashTinkerView.fade()
    }


}





