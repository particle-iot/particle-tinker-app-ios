//
// Created by Raimundas Sakalauskas on 2019-08-14.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let DeviceListFilteringChanged: NSNotification.Name = NSNotification.Name(rawValue: "io.particle.event.DeviceListFilteringChanged")
}


class DeviceListDataSource: NSCopying  {
    public private(set) var devices: [ParticleDevice] = []
    public private(set) var viewDevices: [ParticleDevice] = []

    public private(set) var searchTerm: String?
    public private(set) var sortOption: DeviceListSortingOptions = .onlineStatus
    public private(set) var onlineStatusOptions: [DeviceOnlineStatusOptions] = []
    public private(set) var typeOptions: [DeviceTypeOptions] = []

    func setDevices(_ devices: [ParticleDevice]) {
        self.devices = devices
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
    }

    func setSearchTerm(_ searchTerm: String?) {
        self.searchTerm = searchTerm?.lowercased()
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

        if let searchTerm = searchTerm, searchTerm.count > 0 {
            NSLog("searchTerm = '\(searchTerm)'")
            self.viewDevices = self.viewDevices.filter { (device: ParticleDevice) -> Bool in
                return device.getName().lowercased().contains(searchTerm) ||
                        device.id.lowercased().contains(searchTerm) ||
                        device.imei?.lowercased().contains(searchTerm) ?? false ||
                        device.serialNumber?.lowercased().contains(searchTerm) ?? false ||
                        device.lastIccid?.lowercased().contains(searchTerm) ?? false ||
                        device.lastIPAdress?.lowercased().contains(searchTerm) ?? false ||
                        device.notes?.lowercased().contains(searchTerm) ?? false
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
            let nameA = firstDevice.name?.lowercased() ?? " "
            let nameB = secondDevice.name?.lowercased() ?? " "

            switch self.sortOption {
                case .onlineStatus:
                    if (firstDevice.connected != secondDevice.connected) {
                        return firstDevice.connected == true
                    } else if isSearching() && (nameA.contains(searchTerm!) != nameB.contains(searchTerm!)) {
                        return nameA.contains(searchTerm!)
                    } else {
                        return nameA.lowercased() < nameB.lowercased()
                    }
                case .deviceType:
                    if (firstDevice.type != secondDevice.type) {
                        return firstDevice.type.description.lowercased() < secondDevice.type.description.lowercased()
                    } else if isSearching() && (nameA.contains(searchTerm!) != nameB.contains(searchTerm!)) {
                        return nameA.contains(searchTerm!)
                    } else {
                        return nameA.lowercased() < nameB.lowercased()
                    }
                case .name:
                    if isSearching() && (nameA.contains(searchTerm!) != nameB.contains(searchTerm!)) {
                        return nameA.contains(searchTerm!)
                    } else {
                        return nameA.lowercased() < nameB.lowercased()
                    }
                case .lastHeard:
                    var dateA = firstDevice.lastHeard ?? Date.distantPast
                    var dateB = secondDevice.lastHeard ?? Date.distantPast

                    if (dateA != dateB) {
                        return dateA > dateB
                    } else if isSearching() && (nameA.contains(searchTerm!) != nameB.contains(searchTerm!)) {
                        return nameA.contains(searchTerm!)
                    } else {
                        return nameA.lowercased() < nameB.lowercased()
                    }
            }
        })
    }


    func isSearching() -> Bool {
        if let searchTerm = searchTerm, searchTerm.count > 0 {
            return true
        }

        return false
    }

    func isFiltering() -> Bool {
        if onlineStatusOptions.count > 0, onlineStatusOptions.count < DeviceListSortingOptions.allCases.count {
            return true
        }

        if typeOptions.count > 0, typeOptions.count < DeviceTypeOptions.allCases.count {
            return true
        }

        return false
    }

    func copy(with zone: NSZone?) -> Any {
        let copy = DeviceListDataSource()
        copy.devices = self.devices
        copy.setSearchTerm(self.searchTerm)
        copy.setOnlineStatusOptions(self.onlineStatusOptions)
        copy.setDeviceTypeOptions(self.typeOptions)
        copy.setSortOption(self.sortOption)
        return copy
    }

    func apply(with source: DeviceListDataSource) {
        self.sortOption = source.sortOption
        self.searchTerm = source.searchTerm
        self.typeOptions = source.typeOptions
        self.onlineStatusOptions = source.onlineStatusOptions
        self.reloadData()
        NotificationCenter.default.post(name: .DeviceListFilteringChanged, object: self)
}
}
