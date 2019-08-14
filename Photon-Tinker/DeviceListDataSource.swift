//
// Created by Raimundas Sakalauskas on 2019-08-14.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let DeviceListFilteringChanged: NSNotification.Name = NSNotification.Name(rawValue: "io.particle.event.DeviceListFilteringChanged")
}


class DeviceListDataSource  {
    private(set) public var devices: [ParticleDevice] = []
    private(set) public var viewDevices: [ParticleDevice] = []

    private(set) public var searchTerm: String?
    private(set) public var sortOption: DeviceListSortingOptions = .onlineStatus
    private(set) public var onlineStatusOptions: [DeviceOnlineStatusOptions] = []
    private(set) public var typeOptions: [DeviceTypeOptions] = []

    func setDevices(_ devices: [ParticleDevice]) {
        self.devices = devices
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func setSearchTerm(_ searchTerm: String?) {
        self.searchTerm = searchTerm
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func setSortOption(_ sortOption: DeviceListSortingOptions) {
        self.sortOption = sortOption
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func setOnlineStatusOptions(_ onlineStatusOptions: [DeviceOnlineStatusOptions]) {
        self.onlineStatusOptions = onlineStatusOptions
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func setDeviceTypeOptions(_ deviceTypeOptions: [DeviceTypeOptions]) {
        self.typeOptions = deviceTypeOptions
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func reloadData() {
        self.viewDevices = self.devices

        if let searchTerm = searchTerm {
            NSLog("searchTerm = '\(searchTerm)'")
            self.viewDevices = self.viewDevices.filter { (device: ParticleDevice) -> Bool in
                return device.getName().lowercased().contains(searchTerm)
            }
        }

        if onlineStatusOptions.count > 0, onlineStatusOptions.count < DeviceListSortingOptions.allCases.count {
            NSLog("onlineStatusOptions = \(onlineStatusOptions)")
            self.viewDevices = self.viewDevices.filter { (device: ParticleDevice) -> Bool in
                for option in onlineStatusOptions {
                    if (option.match(device: device)) {
                        return true
                    }
                }
                return false
            }
        }

        if typeOptions.count > 0, typeOptions.count < DeviceTypeOptions.allCases.count {
            NSLog("typeOptions = \(typeOptions)")
            self.viewDevices = self.viewDevices.filter { (device: ParticleDevice) -> Bool in
                for option in typeOptions {
                    if (option.match(device: device)) {
                        return true
                    }
                }
                return false
            }
        }

        self.sortDevices()
    }

    private func sortDevices() {
        self.viewDevices.sort(by: { (firstDevice:ParticleDevice, secondDevice:ParticleDevice) -> Bool in
            switch self.sortOption {
                case .onlineStatus:
                    if (firstDevice.connected != secondDevice.connected) {
                        return firstDevice.connected == true
                    } else {
                        let nameA = firstDevice.name ?? " "
                        let nameB = secondDevice.name ?? " "
                        return nameA.lowercased() < nameB.lowercased()
                    }
                case .deviceType:
                    if (firstDevice.type != secondDevice.type) {
                        return firstDevice.type.description.lowercased() < secondDevice.type.description.lowercased()
                    } else {
                        let nameA = firstDevice.name ?? " "
                        let nameB = secondDevice.name ?? " "
                        return nameA.lowercased() < nameB.lowercased()
                    }
                case .name:
                    let nameA = firstDevice.name ?? " "
                    let nameB = secondDevice.name ?? " "
                    return nameA.lowercased() < nameB.lowercased()
                case .lastHeard:
                    var dateA = firstDevice.lastHeard ?? Date.distantPast
                    var dateB = secondDevice.lastHeard ?? Date.distantPast

                    if (dateA != dateB) {
                        return dateA > dateB
                    } else {
                        let nameA = firstDevice.name ?? " "
                        let nameB = secondDevice.name ?? " "
                        return nameA.lowercased() < nameB.lowercased()
                    }
            }
        })
    }



}
