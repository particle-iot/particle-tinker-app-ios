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
            } else if (subview is ParticleButton) {
                let button = subview as! ParticleButton
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


    struct ControlPanel {
        struct Root {
            static let Title = "MeshSetup.ControlPanel.Root.Title".meshLocalized()

            static let Name = "MeshSetup.ControlPanel.Root.Name".meshLocalized()
            static let Notes = "MeshSetup.ControlPanel.Root.Notes".meshLocalized()
            static let Wifi = "MeshSetup.ControlPanel.Root.Wifi".meshLocalized()
            static let Mesh = "MeshSetup.ControlPanel.Root.Mesh".meshLocalized()
            static let Ethernet = "MeshSetup.ControlPanel.Root.Ethernet".meshLocalized()
            static let Cellular = "MeshSetup.ControlPanel.Root.Cellular".meshLocalized()
            static let Documentation = "MeshSetup.ControlPanel.Root.Documentation".meshLocalized()
            static let UnclaimDevice = "MeshSetup.ControlPanel.Root.UnclaimDevice".meshLocalized()
        }

        struct Unclaim {
            static let Title = "MeshSetup.ControlPanel.Unclaim.Title".meshLocalized()
            static let TextTitle = "MeshSetup.ControlPanel.Unclaim.TextTitle".meshLocalized()
            static let Text = "MeshSetup.ControlPanel.Unclaim.Text".meshLocalized()
            static let UnclaimButton = "MeshSetup.ControlPanel.Unclaim.UnclaimButton".meshLocalized()
        }

        struct Wifi {
            static let Title = "MeshSetup.ControlPanel.Wifi.Title".meshLocalized()

            static let AddNewWifi = "MeshSetup.ControlPanel.Wifi.AddNewWifi".meshLocalized()
            static let ManageWifi = "MeshSetup.ControlPanel.Wifi.ManageWifi".meshLocalized()
        }

        struct Cellular {
            static let Title = "MeshSetup.ControlPanel.Cellular.Title".meshLocalized()

            static let CellularDataTitle = "MeshSetup.ControlPanel.Cellular.CellularDataTitle".meshLocalized()
            static let SimActiveDescription = "MeshSetup.ControlPanel.Cellular.SimActiveDescription".meshLocalized()
            static let SimPausedDescription = "MeshSetup.ControlPanel.Cellular.SimPausedDescription".meshLocalized()
            static let SimDeactivatedDescription = "MeshSetup.ControlPanel.Cellular.SimDeactivatedDescription".meshLocalized()

            static let ChangeSimStatus = "MeshSetup.ControlPanel.Cellular.ChangeSimStatus".meshLocalized()
            static let ChangeDataLimit = "MeshSetup.ControlPanel.Cellular.ChangeDataLimit".meshLocalized()

            static let Active = "MeshSetup.ControlPanel.Cellular.Active".meshLocalized()
            static let Inactive = "MeshSetup.ControlPanel.Cellular.Inactive".meshLocalized()
            static let Paused = "MeshSetup.ControlPanel.Cellular.Paused".meshLocalized()

            struct DataLimit {
                static let Title = "MeshSetup.ControlPanel.Cellular.DataLimit.Title".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.Cellular.DataLimit.Text".meshLocalized()
                static let Note = "MeshSetup.ControlPanel.Cellular.DataLimit.Note".meshLocalized()

                static let DataLimitValue = "MeshSetup.ControlPanel.Cellular.DataLimit.DataLimitValue".meshLocalized()
                static let ContinueButton = "MeshSetup.ControlPanel.Cellular.DataLimit.ContinueButton".meshLocalized()
            }

            struct DeactivateSim {
                static let Title = "MeshSetup.ControlPanel.Cellular.DeactivateSim.Title".meshLocalized()
                static let TextTitle = "MeshSetup.ControlPanel.Cellular.DeactivateSim.TextTitle".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.Cellular.DeactivateSim.Text".meshLocalized()
                static let Note = "MeshSetup.ControlPanel.Cellular.DeactivateSim.Note".meshLocalized()

                static let ContinueButton = "MeshSetup.ControlPanel.Cellular.DeactivateSim.ContinueButton".meshLocalized()
            }

            struct ResumeSim {
                static let Title = "MeshSetup.ControlPanel.Cellular.ResumeSim.Title".meshLocalized()
                static let TextTitle = "MeshSetup.ControlPanel.Cellular.ResumeSim.TextTitle".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.Cellular.ResumeSim.Text".meshLocalized()
                static let Note = "MeshSetup.ControlPanel.Cellular.ResumeSim.Note".meshLocalized()

                static let ContinueButton = "MeshSetup.ControlPanel.Cellular.ResumeSim.ContinueButton".meshLocalized()
            }

            struct ActivateSim {
                static let Title = "MeshSetup.ControlPanel.Cellular.ActivateSim.Title".meshLocalized()
                static let TextTitle = "MeshSetup.ControlPanel.Cellular.ActivateSim.TextTitle".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.Cellular.ActivateSim.Text".meshLocalized()
                static let Note = "MeshSetup.ControlPanel.Cellular.ActivateSim.Note".meshLocalized()

                static let ContinueButton = "MeshSetup.ControlPanel.Cellular.ActivateSim.ContinueButton".meshLocalized()
            }
        }

        struct Ethernet {
            static let Title = "MeshSetup.ControlPanel.Ethernet.Title".meshLocalized()

            static let ChangePinsStatus = "MeshSetup.ControlPanel.Ethernet.ChangePinsStatus".meshLocalized()

            static let Active = "MeshSetup.ControlPanel.Ethernet.Active".meshLocalized()
            static let Inactive = "MeshSetup.ControlPanel.Ethernet.Inactive".meshLocalized()
            static let Footer = "MeshSetup.ControlPanel.Ethernet.Footer".meshLocalized()
        }

        struct Mesh {
            static let Title = "MeshSetup.ControlPanel.Mesh.Title".meshLocalized()

            static let JoinNetwork = "MeshSetup.ControlPanel.Mesh.JoinNetwork".meshLocalized()
            static let CreateNetwork = "MeshSetup.ControlPanel.Mesh.CreateNetwork".meshLocalized()
            static let LeaveNetwork = "MeshSetup.ControlPanel.Mesh.LeaveNetwork".meshLocalized()
            static let PromoteToGateway = "MeshSetup.ControlPanel.Mesh.PromoteToGateway".meshLocalized()
            static let DemoteFromGateway = "MeshSetup.ControlPanel.Mesh.DemoteFromGateway".meshLocalized()
            static let NetworkInfo = "MeshSetup.ControlPanel.Mesh.NetworkInfo".meshLocalized()
            static let NoNetworkInfo = "MeshSetup.ControlPanel.Mesh.NoNetworkInfo".meshLocalized()

            static let NetworkName = "MeshSetup.ControlPanel.Mesh.NetworkName".meshLocalized()
            static let NetworkID = "MeshSetup.ControlPanel.Mesh.NetworkID".meshLocalized()
            static let NetworkExtPanID = "MeshSetup.ControlPanel.Mesh.NetworkExtPanID".meshLocalized()
            static let NetworkPanID = "MeshSetup.ControlPanel.Mesh.NetworkPanID".meshLocalized()
            static let NetworkChannel = "MeshSetup.ControlPanel.Mesh.NetworkChannel".meshLocalized()
        }

        struct Documentation {
            static let Title = "MeshSetup.ControlPanel.Documentation.Title".meshLocalized()
        }

        struct PrepareForPairing {
            static let Title = "MeshSetup.ControlPanel.PrepareForPairing.Title".meshLocalized()

            static let Text = "MeshSetup.ControlPanel.PrepareForPairing.Text".meshLocalized()
            static let Signal = "MeshSetup.ControlPanel.PrepareForPairing.Signal".meshLocalized()
            static let SignalWarning = "MeshSetup.ControlPanel.PrepareForPairing.SignalWarning".meshLocalized()
        }


        struct FlowComplete {
            struct AddNewWifi {
                static let Title = "MeshSetup.ControlPanel.FlowComplete.AddNewWifi.Title".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.FlowComplete.AddNewWifi.Text".meshLocalized()
            }

            struct ChangeDataLimit {
                static let Title = "MeshSetup.ControlPanel.FlowComplete.ChangeDataLimit.Title".meshLocalized()
                static let Text = "MeshSetup.ControlPanel.FlowComplete.ChangeDataLimit.Text".meshLocalized()
            }

            struct ToggleEthernet {
                static let Title = "MeshSetup.ControlPanel.FlowComplete.ToggleEthernet.Title".meshLocalized()
                static let ActivateText = "MeshSetup.ControlPanel.FlowComplete.ToggleEthernet.ActivateText".meshLocalized()
                static let DeactivateText = "MeshSetup.ControlPanel.FlowComplete.ToggleEthernet.DeactivateText".meshLocalized()
            }

            struct ToggleSim {
                static let Title = "MeshSetup.ControlPanel.FlowComplete.ToggleSim.Title".meshLocalized()
                static let ActivateText = "MeshSetup.ControlPanel.FlowComplete.ToggleSim.ActivateText".meshLocalized()
                static let DeactivateText = "MeshSetup.ControlPanel.FlowComplete.ToggleSim.DeactivateText".meshLocalized()
            }

        }
    }

    struct Error {
        //unproofread
        static let CriticalFlowError = "MeshSetup.Error.CriticalFlowError"
        static let SimBelongsToOtherAccount = "MeshSetup.Error.SimBelongsToOtherAccount"
        static let ExternalSimNotSupported = "MeshSetup.Error.ExternalSimNotSupported"
        static let StickerError = "MeshSetup.Error.StickerError"
        static let NetworkError = "MeshSetup.Error.NetworkError"
        static let InvalidDeviceState = "MeshSetup.Error.InvalidDeviceState"
        static let NameInUse = "MeshSetup.Error.NameInUse"
        static let FailedToObtainIpBoron = "MeshSetup.Error.FailedToObtainIpBoron"
        static let WrongTargetDeviceType = "MeshSetup.Error.WrongTargetDeviceType"
        static let WrongCommissionerDeviceType = "MeshSetup.Error.WrongCommissionerDeviceType"
        static let BoronModemError = "MeshSetup.Error.BoronModemError"
        static let FailedToChangeSimDataLimit = "MeshSetup.Error.FailedToChangeSimDataLimit"
        static let FailedToGetDeviceInfo = "MeshSetup.Error.FailedToGetDeviceInfo"


        //these errors are handled instantly
        static let FailedToUpdateDeviceOS = "MeshSetup.Error.FailedToUpdateDeviceOS"
        static let FailedToFlashBecauseOfTimeout = "MeshSetup.Error.FailedToFlashBecauseOfTimeout"
        static let UnableToDownloadFirmwareBinary = "MeshSetup.Error.UnableToDownloadFirmwareBinary"
        static let CannotAddGatewayDeviceAsJoiner = "MeshSetup.Error.CannotAddGatewayDeviceAsJoiner"
        static let WrongNetworkPassword = "MeshSetup.Error.WrongNetworkPassword"
        static let WifiPasswordTooShort = "MeshSetup.Error.WifiPasswordTooShort"
        static let PasswordTooShort = "MeshSetup.Error.PasswordTooShort"
        static let IllegalOperation = "MeshSetup.Error.IllegalOperation"
        static let UnableToRenameDevice = "MeshSetup.Error.UnableToRenameDevice"
        static let NameTooShort = "MeshSetup.Error.NameTooShort"
        //user facing errors
        static let FailedToActivateSim = "MeshSetup.Error.FailedToActivateSim"
        static let FailedToDeactivateSim = "MeshSetup.Error.FailedToDeactivateSim"

        static let CCMissing = "MeshSetup.Error.CCMissing"
        static let UnableToGetPricingInformation = "MeshSetup.Error.UnableToGetPricingInformation"
        static let UnableToGetSimStatus = "MeshSetup.Error.UnableToGetSimStatus"
        static let UnableToPublishDeviceSetupEvent = "MeshSetup.Error.UnableToPublishDeviceSetupEvent"
        static let UnableToLeaveNetwork = "MeshSetup.Error.UnableToLeaveNetwork"
        static let UnableToJoinNetwork = "MeshSetup.Error.UnableToJoinNetwork"
        static let UnableToJoinOldNetwork = "MeshSetup.Error.UnableToJoinOldNetwork"
        static let UnableToRetrieveNetworks = "MeshSetup.Error.UnableToRetrieveNetworks"
        static let UnableToCreateNetwork = "MeshSetup.Error.UnableToCreateNetwork"
        static let UnableToGenerateClaimCode = "MeshSetup.Error.UnableToGenerateClaimCode"
        static let DeviceTooFar = "MeshSetup.Error.DeviceTooFar"
        static let FailedToStartScan = "MeshSetup.Error.FailedToStartScan"
        static let FailedToScanBecauseOfTimeout = "MeshSetup.Error.FailedToScanBecauseOfTimeout"
        static let FailedToConnect = "MeshSetup.Error.FailedToConnect"
        static let BluetoothDisabled = "MeshSetup.Error.BluetoothDisabled"
        static let BluetoothTimeout = "MeshSetup.Error.BluetoothTimeout"
        static let BluetoothError = "MeshSetup.Error.BluetoothError"
        static let CommissionerNetworkDoesNotMatch = "MeshSetup.Error.CommissionerNetworkDoesNotMatch"
        static let SameDeviceScannedTwice = "MeshSetup.Error.SameDeviceScannedTwice"
        static let FailedToObtainIp = "MeshSetup.Error.FailedToObtainIp"
        static let BluetoothConnectionDropped = "MeshSetup.Error.BluetoothConnectionDropped"
        static let DeviceIsNotAllowedToJoinNetwork = "MeshSetup.Error.DeviceIsNotAllowedToJoinNetwork"
        static let DeviceIsUnableToFindNetworkToJoin = "MeshSetup.Error.DeviceIsUnableToFindNetworkToJoin"
        static let DeviceTimeoutWhileJoiningNetwork = "MeshSetup.Error.DeviceTimeoutWhileJoiningNetwork"
        static let DeviceConnectToCloudTimeout = "MeshSetup.Error.DeviceConnectToCloudTimeout"
        static let DeviceGettingClaimedTimeout = "MeshSetup.Error.DeviceGettingClaimedTimeout"
        static let ThisDeviceIsACommissioner = "MeshSetup.Error.ThisDeviceIsACommissioner"
    }

    struct Prompt {
        static let ErrorTitle = "MeshSetup.Prompt.ErrorTitle".meshLocalized()
        static let CancelSetupTitle = "MeshSetup.Prompt.CancelSetupTitle".meshLocalized()
        static let CancelSetupText = "MeshSetup.Prompt.CancelSetupText".meshLocalized()


        static let ControlPanelExternalSimNotSupportedText = "MeshSetup.Prompt.ControlPanelExternalSimNotSupportedText".meshLocalized()

        static let LeaveNetworkTitle = "MeshSetup.Prompt.LeaveNetworkTitle".meshLocalized()
        static let LeaveNetworkText = "MeshSetup.Prompt.LeaveNetworkText".meshLocalized()

        static let NoCameraPermissionsTitle = "MeshSetup.Prompt.NoCameraPermissionsTitle".meshLocalized()
        static let NoCameraPermissionsText = "MeshSetup.Prompt.NoCameraPermissionsText".meshLocalized()

        static let SwitchToControlPanelTitle = "MeshSetup.Prompt.SwitchToControlPanelTitle".meshLocalized()
        static let SwitchToControlPanelText = "MeshSetup.Prompt.SwitchToControlPanelText".meshLocalized()

        static let NoCameraTitle = "MeshSetup.Prompt.NoCameraTitle".meshLocalized()
        static let NoCameraText = "MeshSetup.Prompt.NoCameraText".meshLocalized()
    }

    struct Action {
        static let Ok = "MeshSetup.Action.Ok".meshLocalized()
        static let Cancel = "MeshSetup.Action.Cancel".meshLocalized()
        static let CancelSetup = "MeshSetup.Action.CancelSetup".meshLocalized()
        static let Retry = "MeshSetup.Action.Retry".meshLocalized()
        static let Continue = "MeshSetup.Action.Continue".meshLocalized()
        static let ContinueSetup = "MeshSetup.Action.ContinueSetup".meshLocalized()
        static let LeaveNetwork = "MeshSetup.Action.LeaveNetwork".meshLocalized()
        static let DontLeaveNetwork = "MeshSetup.Action.DontLeaveNetwork".meshLocalized()
        static let ContactSupport = "MeshSetup.Action.ContactSupport".meshLocalized()
        static let OpenSettings = "MeshSetup.Action.OpenSettings".meshLocalized()
        static let SwitchToControlPanel = "MeshSetup.Action.SwitchToControlPanel".meshLocalized()
        static let DontSwitchToControlPanel = "MeshSetup.Action.DontSwitchToControlPanel".meshLocalized()
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
        static let EthernetTitle = "MeshSetup.GetReady.EthernetTitle".meshLocalized()

        static let EthernetToggleTitle = "MeshSetup.GetReady.EthernetToggleTitle".meshLocalized()
        static let EthernetToggleText = "MeshSetup.GetReady.EthernetToggleText".meshLocalized()

        static let WifiCheckboxText = "MeshSetup.GetReady.WifiCheckboxText".meshLocalized()
        static let CellularCheckboxText = "MeshSetup.GetReady.CellularCheckboxText".meshLocalized()

        static let SOMTitle = "MeshSetup.GetReady.SOMTitle".meshLocalized()
        static let SOMEthernetTitle = "MeshSetup.GetReady.SOMEthernetTitle".meshLocalized()

        static let SOMEthernetToggleTitle = "MeshSetup.GetReady.SOMEthernetToggleTitle".meshLocalized()
        static let SOMEthernetToggleText = "MeshSetup.GetReady.SOMEthernetToggleText".meshLocalized()

        static let SOMWifiCheckboxText = "MeshSetup.GetReady.SOMWifiCheckboxText".meshLocalized()
        static let SOMCellularCheckboxText = "MeshSetup.GetReady.SOMCellularCheckboxText".meshLocalized()
        static let SOMBluetoothCheckboxText = "MeshSetup.GetReady.SOMBluetoothCheckboxText".meshLocalized()
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

    struct SelectNetwork {
        static let Title = "MeshSetup.SelectNetwork.Title".meshLocalized()
        static let DevicesSingular = "MeshSetup.SelectNetwork.DevicesSingular".meshLocalized()
        static let DevicesPlural = "MeshSetup.SelectNetwork.DevicesPlural".meshLocalized()
    }

    struct SelectWifiNetwork {
        static let Title = "MeshSetup.SelectWifiNetwork.Title".meshLocalized()
    }


    struct ExistingNetworkPassword {
        static let Title = "MeshSetup.ExistingNetworkPassword.Title".meshLocalized()
        static let InputTitle = "MeshSetup.ExistingNetworkPassword.InputTitle".meshLocalized()
        static let NoteTitle = "MeshSetup.ExistingNetworkPassword.NoteTitle".meshLocalized()
        static let NoteText = "MeshSetup.ExistingNetworkPassword.NoteText".meshLocalized()
        static let Button = "MeshSetup.ExistingNetworkPassword.Button".meshLocalized()
    }

    struct WifiNetworkPassword {
        static let Title = "MeshSetup.WifiNetworkPassword.Title".meshLocalized()
        static let InputTitle = "MeshSetup.WifiNetworkPassword.InputTitle".meshLocalized()
        static let Button = "MeshSetup.WifiNetworkPassword.Button".meshLocalized()
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


    struct ConnectingToInternetEthernet {
        static let Title = "MeshSetup.ConnectingToInternetEthernet.Title".meshLocalized()
        static let Text1 = "MeshSetup.ConnectingToInternetEthernet.Text1".meshLocalized()
        static let Text2 = "MeshSetup.ConnectingToInternetEthernet.Text2".meshLocalized()

        static let SuccessTitle = "MeshSetup.ConnectingToInternetEthernet.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.ConnectingToInternetEthernet.SuccessText".meshLocalized()
    }

    struct ConnectingToInternetWifi {
        static let Title = "MeshSetup.ConnectingToInternetWifi.Title".meshLocalized()
        static let Text1 = "MeshSetup.ConnectingToInternetWifi.Text1".meshLocalized()
        static let Text2 = "MeshSetup.ConnectingToInternetWifi.Text2".meshLocalized()

        static let SuccessTitle = "MeshSetup.ConnectingToInternetWifi.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.ConnectingToInternetWifi.SuccessText".meshLocalized()
    }

    struct ConnectingToInternetCellular {
        static let Title = "MeshSetup.ConnectingToInternetCellular.Title".meshLocalized()
        static let Text1 = "MeshSetup.ConnectingToInternetCellular.Text1".meshLocalized()
        static let Text2 = "MeshSetup.ConnectingToInternetCellular.Text2".meshLocalized()
        static let Text3 = "MeshSetup.ConnectingToInternetCellular.Text3".meshLocalized()

        static let SuccessTitle = "MeshSetup.ConnectingToInternetCellular.SuccessTitle".meshLocalized()
        static let SuccessText = "MeshSetup.ConnectingToInternetCellular.SuccessText".meshLocalized()
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


    struct JoinerInfo {
        static let Title = "MeshSetup.JoinerInfo.Title".meshLocalized()
        static let Text1 = "MeshSetup.JoinerInfo.Text1".meshLocalized()
        static let Text2 = "MeshSetup.JoinerInfo.Text2".meshLocalized()
        static let Text3 = "MeshSetup.JoinerInfo.Text3".meshLocalized()
        static let Button = "MeshSetup.JoinerInfo.Button".meshLocalized()
    }

    struct GatewayInfoEthernetStandalone {
        static let Title = "MeshSetup.GatewayInfoEthernetStandalone.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoEthernetStandalone.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoEthernetStandalone.Text2".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoEthernetStandalone.Button".meshLocalized()
    }

    struct GatewayInfoEthernetMesh {
        static let Title = "MeshSetup.GatewayInfoEthernetMesh.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoEthernetMesh.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoEthernetMesh.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GatewayInfoEthernetMesh.Text3".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoEthernetMesh.Button".meshLocalized()
    }





    struct GatewayInfoWifiStandalone {
        static let Title = "MeshSetup.GatewayInfoWifiStandalone.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoWifiStandalone.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoWifiStandalone.Text2".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoWifiStandalone.Button".meshLocalized()
    }

    struct GatewayInfoWifiMesh {
        static let Title = "MeshSetup.GatewayInfoWifiMesh.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoWifiMesh.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoWifiMesh.Text2".meshLocalized()
        static let Text3 = "MeshSetup.GatewayInfoWifiMesh.Text3".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoWifiMesh.Button".meshLocalized()
    }


    struct GatewayInfoCellularStandalone {
        static let Title = "MeshSetup.GatewayInfoCellularStandalone.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoCellularStandalone.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoCellularStandalone.Text2".meshLocalized()
        static let Text2Activate = "MeshSetup.GatewayInfoCellularStandalone.Text2Activate".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoCellularStandalone.Button".meshLocalized()
        static let ButtonActivate = "MeshSetup.GatewayInfoCellularStandalone.ButtonActivate".meshLocalized()
    }

    struct GatewayInfoCellularMesh {
        static let Title = "MeshSetup.GatewayInfoCellularMesh.Title".meshLocalized()
        static let Text1 = "MeshSetup.GatewayInfoCellularMesh.Text1".meshLocalized()
        static let Text2 = "MeshSetup.GatewayInfoCellularMesh.Text2".meshLocalized()
        static let Text2Activate = "MeshSetup.GatewayInfoCellularMesh.Text2Activate".meshLocalized()
        static let Text3 = "MeshSetup.GatewayInfoCellularMesh.Text3".meshLocalized()
        static let Button = "MeshSetup.GatewayInfoCellularMesh.Button".meshLocalized()
        static let ButtonActivate = "MeshSetup.GatewayInfoCellularMesh.ButtonActivate".meshLocalized()
    }


    struct PricingInfo {
        static let FreeNetworkTitle = "MeshSetup.PricingInfo.FreeNetworkTitle".meshLocalized()
        static let PaidNetworkTitle = "MeshSetup.PricingInfo.PaidNetworkTitle".meshLocalized()

        static let FreeGatewayDeviceTitle = "MeshSetup.PricingInfo.FreeGatewayDeviceTitle".meshLocalized()
        static let PaidGatewayDeviceTitle = "MeshSetup.PricingInfo.PaidGatewayDeviceTitle".meshLocalized()

        static let DeviceCloudPlanTitle = "MeshSetup.PricingInfo.DeviceCloudPlanTitle".meshLocalized()
        static let MicroNetworkPlanTitle = "MeshSetup.PricingInfo.MicroNetworkPlanTitle".meshLocalized()

        static let WifiDeviceText = "MeshSetup.PricingInfo.WifiDeviceText".meshLocalized()
        static let WifiGatewayText = "MeshSetup.PricingInfo.WifiGatewayText".meshLocalized()

        static let CellularDeviceText = "MeshSetup.PricingInfo.CellularDeviceText".meshLocalized()
        static let CellularGatewayText = "MeshSetup.PricingInfo.CellularGatewayText".meshLocalized()

        static let FreeDevicesText = "MeshSetup.PricingInfo.FreeDevicesText".meshLocalized()
        static let FreeNetworksText = "MeshSetup.PricingInfo.FreeNetworksText".meshLocalized()
        static let FreeMonthsText = "MeshSetup.PricingInfo.FreeMonthsText".meshLocalized()

        static let PriceText = "MeshSetup.PricingInfo.PriceText".meshLocalized()
        static let PriceNoteText = "MeshSetup.PricingInfo.PriceNoteText".meshLocalized()

        static let DeviceCloudFeatures = "MeshSetup.PricingInfo.DeviceCloudFeatures".meshLocalized()
        static let MeshNetworkFeatures = "MeshSetup.PricingInfo.MeshNetworkFeatures".meshLocalized()

        static let FeaturesDeviceCloud = "MeshSetup.PricingInfo.FeaturesDeviceCloud".meshLocalized()
        static let FeaturesMaxDevices = "MeshSetup.PricingInfo.FeaturesMaxDevices".meshLocalized()
        static let FeaturesMaxGateways = "MeshSetup.PricingInfo.FeaturesMaxGateways".meshLocalized()
        static let FeaturesDataAllowence = "MeshSetup.PricingInfo.FeaturesDataAllowence".meshLocalized()
        static let FeaturesStandardSupport = "MeshSetup.PricingInfo.FeaturesStandardSupport".meshLocalized()

        static let ButtonNext = "MeshSetup.PricingInfo.ButtonNext".meshLocalized()
        static let ButtonEnroll = "MeshSetup.PricingInfo.ButtonEnroll".meshLocalized()
    }
}
