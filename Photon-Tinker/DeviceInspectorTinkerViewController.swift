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
                    var tutorial2 = YCTutorialBox(headline: TinkerStrings.Tinker.Tutorial.Tutorial2.Title, withHelpText: TinkerStrings.Tinker.Tutorial.Tutorial2.Message)

                    // 1
                    var tutorial = YCTutorialBox(headline: TinkerStrings.Tinker.Tutorial.Tutorial1.Title, withHelpText: TinkerStrings.Tinker.Tutorial.Tutorial1.Message) {
                        tutorial2?.showAndFocus(self.tinkerView.pinViews["D7"])
                    }
                    tutorial?.showAndFocus(self.view)

                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
            }

        }
    }

    @IBAction func flashTinkerButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: TinkerStrings.Tinker.Prompt.FlashTinker.Title, message: TinkerStrings.Tinker.Prompt.FlashTinker.Message, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Flash, style: .default, handler: { action in
            self.flashTinker()
        }))

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel, handler: nil ))

        self.present(alert, animated: true)
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

                        DispatchQueue.main.async {
                            RMessage.showNotification(withTitle: TinkerStrings.Tinker.Error.FlashingDeviceError.Title, subtitle: TinkerStrings.Tinker.Error.FlashingDeviceError.Message.replacingOccurrences(of: "{{error}}", with: e.localizedDescription), type: .error, customTypeName: nil, duration: -1, callback: nil)
                        }
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
            case .bSoMCat1:
                flashTinkerBinary("b5som-tinker@1.4.5-b5som.2.bin")
            case .xenon:
                flashTinkerBinary("tinker-0.8.0-rc.27-xenon")
            default:
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: TinkerStrings.Tinker.Error.DeviceNotSupported.Title, subtitle: TinkerStrings.Tinker.Error.DeviceNotSupported.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                }
                return
        }

        self.flashStarted = true
        self.flashTinkerView.fade()
    }


}





