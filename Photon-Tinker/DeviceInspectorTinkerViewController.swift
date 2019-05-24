//
// Created by Raimundas Sakalauskas on 2019-05-13.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorTinkerViewController: DeviceInspectorChildViewController {

    @IBOutlet var tinkerView: TinkerView!
    @IBOutlet var flashTinkerView: UIView!
    @IBOutlet var deviceOfflineView: UIView!
    
    private var flashStarted: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
        self.tinkerView.setup(device)
    }

    override func setup(device: ParticleDevice) {
        super.setup(device: device)
    }
    
    

    override func update() {
        super.update()

        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

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

    override func resetUserAppData() {
        super.resetUserAppData()

        self.flashStarted = false
    }

    override func showTutorial() {

    }
}



