//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation


extension UIView {
    open func replaceMeshSetupStrings(deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) {
        let subviews = self.subviews

        for subview in subviews {
            if subview is UILabel {
                let label = subview as! UILabel
                label.text = label.text?.replaceMeshSetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName)
            } else if (subview is MeshSetupButton) {
                let button = subview as! MeshSetupButton
                button.setTitle(button.currentTitle?.replaceMeshSetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName), for: .normal)
            } else if (subview is UIView) {
                subview.replaceMeshSetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName)
            }
        }
    }
}




extension String {
    func meshLocalized() -> String {
        return NSLocalizedString(self, tableName: "MeshSetupStrings", comment: "")
    }

    func replaceMeshSetupStrings(deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) -> String {
        var string = self

        if let t = deviceType {
            string = string.replacingOccurrences(of: "{{device}}", with: t.description, options: CompareOptions.caseInsensitive)
        }

        if let n = networkName {
            string = string.replacingOccurrences(of: "{{network}}", with: n, options: CompareOptions.caseInsensitive)
        }

        if let d = deviceName {
            string = string.replacingOccurrences(of: "{{deviceName}}", with: d, options: CompareOptions.caseInsensitive)
        }

        return string
    }
}


class MeshSetupStrings {
    struct SelectDevice {
        static let Title = "MeshSetup.SelectDevice.Title".meshLocalized()
        static let MeshOnly = "MeshSetup.SelectDevice.MeshOnly".meshLocalized()
        static let MeshAndWifi = "MeshSetup.SelectDevice.MeshAndWifi".meshLocalized()
        static let MeshAndCellular = "MeshSetup.SelectDevice.MeshAndCellular".meshLocalized()
    }

    struct GetReady {
        static let Title = "MeshSetup.GetReady.Title".meshLocalized()
        static let Text1 = "MeshSetup.GetReady.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GetReady.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GetReady.Text3".meshLocalized()
        static let Button = "MeshSetup.GetReady.Button".meshLocalized()
    }

    struct GetCommissionerReady {
        static let Title = "MeshSetup.GetCommissionerReady.Title".meshLocalized()
        static let Text1 = "MeshSetup.GetCommissionerReady.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GetCommissionerReady.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GetCommissionerReady.Text3".meshLocalized()
        static let Button = "MeshSetup.GetCommissionerReady.Button".meshLocalized()
    }

    struct FindSticker {
        static let Title = "MeshSetup.FindSticker.Title".meshLocalized()
        static let Text = "MeshSetup.FindSticker.Text".meshLocalized()
        static let Button = "MeshSetup.FindSticker.Button".meshLocalized()
    }

    struct FindCommissionerSticker {
        static let Title = "MeshSetup.FindCommissionerSticker.Title".meshLocalized()
        static let Text = "MeshSetup.FindCommissionerSticker.Text".meshLocalized()
        static let Note = "MeshSetup.FindCommissionerSticker.Note".meshLocalized()
        static let Button = "MeshSetup.FindCommissionerSticker.Button".meshLocalized()
    }

    struct ScanSticker {
        static let Title = "MeshSetup.ScanSticker.Title".meshLocalized()
        static let Text = "MeshSetup.ScanSticker.Text".meshLocalized()
    }

    struct ScanCommissionerSticker {
        static let Title = "MeshSetup.ScanCommissionerSticker.Title".meshLocalized()
        static let Text = "MeshSetup.ScanCommissionerSticker.Text".meshLocalized()
    }

    struct Pairing {
        static let PairingText = "MeshSetup.Pairing.PairingText".meshLocalized()

        static let SuccessTitle = "MeshSetup.Pairing.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.Pairing.SuccessText".meshLocalized()
    }

    struct PairingCommissioner {
        static let PairingText = "MeshSetup.PairingCommissioner.PairingText".meshLocalized()

        static let SuccessTitle = "MeshSetup.PairingCommissioner.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.PairingCommissioner.SuccessText".meshLocalized()
    }

    struct Networks {
        static let Title = "MeshSetup.Networks.Title".meshLocalized()
    }


    struct ExistingNetworkPassword {
        static let Title = "MeshSetup.ExistingNetworkPassword.Title".meshLocalized()
        static let Text = "MeshSetup.ExistingNetworkPassword.Text".meshLocalized()
        static let Button = "MeshSetup.ExistingNetworkPassword.Button".meshLocalized()
    }


    struct JoiningNetwork {
        static let Title = "MeshSetup.JoiningNetwork.Title".meshLocalized()
        static let Text1 = "MeshSetup.JoiningNetwork.Text1".meshLocalized()
        static let Text2 = "MeshSetup.JoiningNetwork.Text2".meshLocalized()
        static let Text3 = "MeshSetup.JoiningNetwork.Text3".meshLocalized()

        static let SuccessTitle = "MeshSetup.JoiningNetwork.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.JoiningNetwork.SuccessText".meshLocalized()
    }


    struct DeviceName {
        static let Title = "MeshSetup.DeviceName.Title".meshLocalized()
        static let Text = "MeshSetup.DeviceName.Text".meshLocalized()
        static let Button = "MeshSetup.DeviceName.Button".meshLocalized()
    }


    struct Success {
        static let SuccessTitle = "MeshSetup.Success.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.Success.SuccessText".meshLocalized()

        static let SetupAnotherLabel = "MeshSetup.Success.SetupAnotherLabel".meshLocalized()
        static let SetupAnotherButton = "MeshSetup.Success.SetupAnotherButton".meshLocalized()

        static let DoneLabel = "MeshSetup.Success.DoneLabel".meshLocalized()
        static let DoneButton = "MeshSetup.Success.DoneButton".meshLocalized()
    }
}
