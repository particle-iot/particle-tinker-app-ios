//
// Created by Raimundas Sakalauskas on 2019-08-13.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceListDataSource: NSObject, UITableViewDataSource {


    var devices: [ParticleDevice] = []
    var viewDevices: [ParticleDevice] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") as! DeviceListTableViewCell
        cell.setup(device: self.viewDevices[indexPath.row])
        return cell
    }

}
