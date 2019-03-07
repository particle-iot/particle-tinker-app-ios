//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepCheckTargetDeviceHasNetworkInterfaces : MeshSetupStep {
    override func start() {
        context?.targetDevice.transceiver!.sendGetInterfaceList { [weak self, weak context] result, interfaces in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetInterfaceList: \(result.description()), networkCount: \(interfaces?.count as Optional)")
            self.log("\(interfaces as Optional)")

            if (result == .NONE) {
                context.targetDevice.activeInternetInterface = nil

                context.targetDevice.networkInterfaces = interfaces!

                for interface in interfaces! {
                    if (interface.type == .ethernet) {
                        //top priority
                        context.targetDevice.activeInternetInterface = .ethernet
                    } else if (interface.type == .wifi) {
                        //has priority over .ppp, but not over .ethernet
                        if (context.targetDevice.activeInternetInterface == nil || context.targetDevice.activeInternetInterface! == .ppp) {
                            context.targetDevice.activeInternetInterface = .wifi
                        }
                    } else if (interface.type == .ppp) {
                        //lowest priority, only set if there's no other interface
                        if (context.targetDevice.activeInternetInterface == nil) {
                            context.targetDevice.activeInternetInterface = .ppp
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
