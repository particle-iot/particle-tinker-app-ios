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
        } else {
            string = string.replacingOccurrences(of: "{{device}}", with: MeshSetupStrings.Default.DeviceType, options: CompareOptions.caseInsensitive)
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
    static private let randomNames = ["aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "maker", "splendid", "sparkling", "dentist", "doctor", "green", "easter", "ferret", "gerbil", "hacker", "hamster", "wizard", "hobbit", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "burrito", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie"]
    static func getRandomDeviceName() -> String {
        return "\(MeshSetupStrings.randomNames.randomElement()!)_\(MeshSetupStrings.randomNames.randomElement()!)"
    }

    struct Prompt {
        static let ErrorTitle = "MeshSetup.Prompt.ErrorTitle".meshLocalized()
        static let CancelSetupTitle = "MeshSetup.Prompt.CancelSetupTitle".meshLocalized()
        static let CancelSetupText = "MeshSetup.Prompt.CancelSetupText".meshLocalized()
    }

    struct Action {
        static let Ok = "MeshSetup.Action.Ok".meshLocalized()
        static let Cancel = "MeshSetup.Action.Cancel".meshLocalized()
        static let CancelSetup = "MeshSetup.Action.CancelSetup".meshLocalized()
        static let Retry = "MeshSetup.Action.Retry".meshLocalized()
        static let Continue = "MeshSetup.Action.Continue".meshLocalized()
        static let ContinueSetup = "MeshSetup.Action.ContinueSetup".meshLocalized()
    }



    struct Default {
        static let DeviceType = "MeshSetup.Default.DeviceType".meshLocalized()
    }

    struct SelectDevice {
        static let Title = "MeshSetup.SelectDevice.Title".meshLocalized()
        static let MeshOnly = "MeshSetup.SelectDevice.MeshOnly".meshLocalized()
        static let MeshAndWifi = "MeshSetup.SelectDevice.MeshAndWifi".meshLocalized()
        static let MeshAndCellular = "MeshSetup.SelectDevice.MeshAndCellular".meshLocalized()
    }

    struct GetReady {
        static let Button = "MeshSetup.GetReady.Button".meshLocalized()

        static let Title = "MeshSetup.GetReady.Title".meshLocalized()
        static let Text1 = "MeshSetup.GetReady.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GetReady.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GetReady.Text3".meshLocalized()
        static let Text4 = "MeshSetup.GetReady.Text4".meshLocalized()

        static let EthernetTitle = "MeshSetup.GetReady.EthernetTitle".meshLocalized()
        static let EthernetText1 = "MeshSetup.GetReady.EthernetText1".meshLocalized()
        static let EthernetText2 = "MeshSetup.GetReady.EthernetText2".meshLocalized()
        static let EthernetText3 = "MeshSetup.GetReady.EthernetText3".meshLocalized()
        static let EthernetText4 = "MeshSetup.GetReady.EthernetText4".meshLocalized()

        static let EthernetToggleTitle = "MeshSetup.GetReady.EthernetToggleTitle".meshLocalized()
        static let EthernetToggleText = "MeshSetup.GetReady.EthernetToggleText".meshLocalized()
    }

    struct GetCommissionerReady {
        static let Title = "MeshSetup.GetCommissionerReady.Title".meshLocalized()
        static let Text1 = "MeshSetup.GetCommissionerReady.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GetCommissionerReady.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GetCommissionerReady.Text3".meshLocalized()
        static let Text4 = "MeshSetup.GetCommissionerReady.Text4".meshLocalized()
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
        static let NoteText = "MeshSetup.FindCommissionerSticker.NoteText".meshLocalized()
        static let NoteTitle = "MeshSetup.FindCommissionerSticker.NoteTitle".meshLocalized()
        static let Button = "MeshSetup.FindCommissionerSticker.Button".meshLocalized()
    }


    struct StandAloneOrMeshSetup {
        static let Title = "MeshSetup.StandAloneOrMeshSetup.Title".meshLocalized()
        static let Text = "MeshSetup.StandAloneOrMeshSetup.Text".meshLocalized()
        static let MeshButton = "MeshSetup.StandAloneOrMeshSetup.MeshButton".meshLocalized()
        static let StandAloneButton = "MeshSetup.StandAloneOrMeshSetup.StandAloneButton".meshLocalized()

    }


    struct UpdateFirmware {
        static let Title = "MeshSetup.UpdateFirmware.Title".meshLocalized()
        static let Text = "MeshSetup.UpdateFirmware.Text".meshLocalized()

        static let NoteText = "MeshSetup.UpdateFirmware.NoteText".meshLocalized()
        static let NoteTitle = "MeshSetup.UpdateFirmware.NoteTitle".meshLocalized()

        static let Button = "MeshSetup.UpdateFirmware.Button".meshLocalized()
    }


    struct UpdateFirmwareProgress {
        static let Title = "MeshSetup.UpdateFirmwareProgress.Title".meshLocalized()
        static let TextInstalling = "MeshSetup.UpdateFirmwareProgress.TextInstalling".meshLocalized()
        static let Text = "MeshSetup.UpdateFirmwareProgress.Text".meshLocalized()

        static let NoteText = "MeshSetup.UpdateFirmwareProgress.NoteText".meshLocalized()
        static let NoteTitle = "MeshSetup.UpdateFirmwareProgress.NoteTitle".meshLocalized()

        static let SuccessTitle = "MeshSetup.UpdateFirmwareProgress.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.UpdateFirmwareProgress.SuccessText".meshLocalized()
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
        static let InputTitle = "MeshSetup.ExistingNetworkPassword.InputTitle".meshLocalized()
        static let NoteTitle = "MeshSetup.ExistingNetworkPassword.NoteTitle".meshLocalized()
        static let NoteText = "MeshSetup.ExistingNetworkPassword.NoteText".meshLocalized()
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
        static let InputTitle = "MeshSetup.DeviceName.InputTitle".meshLocalized()
        static let NoteTitle = "MeshSetup.DeviceName.NoteTitle".meshLocalized()
        static let NoteText = "MeshSetup.DeviceName.NoteText".meshLocalized()
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


    struct ConnectToInternet {
        static let Title = "MeshSetup.ConnectToInternet.Title".meshLocalized()
        static let Text1 = "MeshSetup.ConnectToInternet.Text1".meshLocalized()
        static let Text2 = "MeshSetup.ConnectToInternet.Text2".meshLocalized()

        static let SuccessTitle = "MeshSetup.ConnectToInternet.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.ConnectToInternet.SuccessText".meshLocalized()
    }





    struct CreateOrSelectNetwork {
        static let Title = "MeshSetup.CreateOrSelectNetwork.Title".meshLocalized()
        static let CreateNetwork = "MeshSetup.CreateOrSelectNetwork.CreateNetwork".meshLocalized()
    }


    struct CreateNetworkName {
        static let Title = "MeshSetup.CreateNetworkName.Title".meshLocalized()
        static let InputTitle = "MeshSetup.CreateNetworkName.InputTitle".meshLocalized()
        static let NoteTitle = "MeshSetup.CreateNetworkName.NoteTitle".meshLocalized()
        static let NoteText = "MeshSetup.CreateNetworkName.NoteText".meshLocalized()
        static let Button = "MeshSetup.CreateNetworkName.Button".meshLocalized()
    }


    struct CreateNetworkPassword {
        static let Title = "MeshSetup.CreateNetworkPassword.Title".meshLocalized()
        static let NoteTitle = "MeshSetup.CreateNetworkPassword.NoteTitle".meshLocalized()
        static let NoteText = "MeshSetup.CreateNetworkPassword.NoteText".meshLocalized()
        static let InputTitle = "MeshSetup.CreateNetworkPassword.InputTitle".meshLocalized()
        static let RepeatTitle = "MeshSetup.CreateNetworkPassword.RepeatTitle".meshLocalized()
        static let Button = "MeshSetup.CreateNetworkPassword.Button".meshLocalized()
        static let PasswordsDoNotMatch = "MeshSetup.CreateNetworkPassword.PasswordsDoNotMatch".meshLocalized()

    }



    struct CreatingNetwork {
        static let Title = "MeshSetup.CreatingNetwork.Title".meshLocalized()
        static let Text1 = "MeshSetup.CreatingNetwork.Text1".meshLocalized()
        static let Text2 = "MeshSetup.CreatingNetwork.Text2".meshLocalized()
        static let Text3 = "MeshSetup.CreatingNetwork.Text3".meshLocalized()
        static let Text4 = "MeshSetup.CreatingNetwork.Text4".meshLocalized()

        static let SuccessTitle = "MeshSetup.CreatingNetwork.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.CreatingNetwork.SuccessText".meshLocalized()
    }


    struct NetworkCreated {
        static let SuccessTitle = "MeshSetup.NetworkCreated.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.NetworkCreated.SuccessText".meshLocalized()

        static let ContinueSetupLabel = "MeshSetup.NetworkCreated.ContinueSetupLabel".meshLocalized()
        static let ContinueSetupButton = "MeshSetup.NetworkCreated.ContinueSetupButton".meshLocalized()

        static let DoneLabel = "MeshSetup.NetworkCreated.DoneLabel".meshLocalized()
        static let DoneButton = "MeshSetup.NetworkCreated.DoneButton".meshLocalized()
    }




    struct GatewayInfoArgonStandalone {
        static let Title = "MeshSetup.GatewayInfoArgonStandalone.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoArgonStandalone.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoArgonStandalone.Text2".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoArgonStandalone.Button".meshLocalized()
    }

    struct GatewayInfoArgonMesh {
        static let Title = "MeshSetup.GatewayInfoArgonMesh.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoArgonMesh.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoArgonMesh.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GatewayInfoArgonMesh.Text3".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoArgonMesh.Button".meshLocalized()
    }


    struct GatewayInfoBoronStandalone {
        static let Title = "MeshSetup.GatewayInfoBoronStandalone.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoBoronStandalone.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoBoronStandalone.Text2".meshLocalized()
        static let Text2Text2Activate = "MeshSetup.GatewayInfoBoronStandalone.Text2Activate".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoBoronStandalone.Button".meshLocalized()
        static let ButtonActivate = "MeshSetup.GatewayInfoBoronStandalone.ButtonActivate".meshLocalized()
    }

    struct GatewayInfoBoronMesh {
        static let Title = "MeshSetup.GatewayInfoBoronMesh.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoBoronMesh.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoBoronMesh.Text2".meshLocalized()
        static let Text2Activate = "MeshSetup.GatewayInfoBoronMesh.Text2Activate".meshLocalized()
        static let Text3 = "MeshSetup.GatewayInfoBoronMesh.Text3".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoBoronMesh.Button".meshLocalized()
        static let ButtonActivate = "MeshSetup.GatewayInfoBoronMesh.ButtonActivate".meshLocalized()
    }
}
