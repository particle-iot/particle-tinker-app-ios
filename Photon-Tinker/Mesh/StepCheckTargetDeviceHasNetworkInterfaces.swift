//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepCheckTargetDeviceHasNetworkInterfaces : MeshSetupStep {
    override func start() {
        self.context.targetDevice.transceiver!.sendGetInterfaceList { result, interfaces in
            self.log("targetDevice.sendGetInterfaceList: \(result.description()), networkCount: \(interfaces?.count as Optional)")
            self.log("\(interfaces as Optional)")

            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.context.targetDevice.activeInternetInterface = nil

                self.context.targetDevice.networkInterfaces = interfaces!

                for interface in interfaces! {
                    if (interface.type == .ethernet) {
                        //top priority
                        self.context.targetDevice.activeInternetInterface = .ethernet
                    } else if (interface.type == .wifi) {
                        //has priority over .ppp, but not over .ethernet
                        if (self.context.targetDevice.activeInternetInterface == nil || self.context.targetDevice.activeInternetInterface! == .ppp) {
                            self.context.targetDevice.activeInternetInterface = .wifi
                        }
                    } else if (interface.type == .ppp) {
                        //lowest priority, only set if there's no other interface
                        if (self.context.targetDevice.activeInternetInterface == nil) {
                            self.context.targetDevice.activeInternetInterface = .ppp
                        }
                    }
                }

                self.stepCompleted()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
