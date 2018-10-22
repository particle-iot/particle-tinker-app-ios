//
//  MeshSetupFlowDefinitions.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 10/10/2018.
//  Copyright © 2018 spark. All rights reserved.
//

import Foundation

//delegate required to request / deliver information from / to the UI
protocol MeshSetupFlowManagerDelegate {
    func meshSetupDidRequestTargetDeviceInfo()

    func meshSetupDidRequestToShowInfo(gatewayFlow: Bool)

    func meshSetupDidRequestToUpdateFirmware()
    func meshSetupDidRequestToLeaveNetwork(network: MeshSetupNetworkInfo)

    func didRequestToSelectStandAloneOrMeshSetup()

    func meshSetupDidRequestToSelectNetwork(availableNetworks: [MeshSetupNetworkInfo])
    func meshSetupDidRequestToSelectWifiNetwork(availableNetworks: [MeshSetupNewWifiNetworkInfo])

    func meshSetupDidRequestCommissionerDeviceInfo()

    func meshSetupDidRequestToEnterSelectedWifiNetworkPassword()
    func meshSetupDidRequestToEnterSelectedNetworkPassword()
    func meshSetupDidRequestToEnterDeviceName()
    func meshSetupDidRequestToAddOneMoreDevice()

    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [MeshSetupNetworkInfo])

    func meshSetupDidRequestToEnterNewNetworkNameAndPassword()
    func meshSetupDidCreateNetwork(network: MeshSetupNetworkInfo)


    func meshSetupDidEnterState(state: MeshSetupFlowState)
    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?)
}


internal enum MeshSetupFlowCommand {

    //preflow
    case GetTargetDeviceInfo
    case ConnectToTargetDevice
    case EnsureCorrectEthernetFeatureStatus
    case EnsureLatestFirmware
    case EnsureTargetDeviceCanBeClaimed
    case CheckTargetDeviceHasNetworkInterfaces
    case OfferSetupStandAloneOrWithNetwork
    case ChooseFlow

    //main flow
    case GetAPINetworks
    case SetClaimCode
    case EnsureTargetDeviceIsNotOnMeshNetwork
    case GetUserNetworkSelection
    case GetCommissionerDeviceInfo
    case ConnectToCommissionerDevice
    case EnsureCommissionerNetworkMatches
    case EnsureCorrectSelectedNetworkPassword
    case JoinSelectedNetwork
    case FinishJoinSelectedNetwork
    case GetNewDeviceName
    case OfferToAddOneMoreDevice

    //gateway
    case GetUserWifiNetworkSelection
    case ShowInfo
    case EnsureCorrectSelectedWifiNetworkPassword
    case EnsureHasInternetAccess
    case CheckDeviceGotClaimed
    case StopTargetDeviceListening
    //case OfferSelectOrCreateNetwork
    case ChooseSubflow


    case GetNewNetworkNameAndPassword
    case CreateNetwork
}


enum MeshSetupFlowState {
    case TargetDeviceConnecting
    case TargetDeviceConnected
    case TargetDeviceReady

    case TargetDeviceScanningForNetworks
    case TargetGatewayDeviceScanningForNetworks
    case TargetDeviceScanningForWifiNetworks

    case TargetDeviceConnectingToInternetStarted
    case TargetDeviceConnectingToInternetStep1Done
    case TargetDeviceConnectingToInternetStep2Done
    case TargetDeviceConnectingToInternetCompleted

    case CommissionerDeviceConnecting
    case CommissionerDeviceConnected
    case CommissionerDeviceReady

    case JoiningNetworkStarted
    case JoiningNetworkStep1Done
    case JoiningNetworkStep2Done
    case JoiningNetworkCompleted

    case FirmwareUpdateProgress
    case FirmwareUpdateFileComplete
    case FirmwareUpdateComplete

    case CreateNetworkStarted
    case CreateNetworkStep1Done
    case CreateNetworkStep2Done
    case CreateNetworkStep3Done
    case CreateNetworkCompleted

    case SetupComplete
    case SetupCanceled
}

enum MeshSetupFlowError: Error, CustomStringConvertible {
    //trying to perform action at the wrong time
    case IllegalOperation

    //EnsureTargetDeviceCanBeClaimed
    case UnableToGenerateClaimCode

    //ConnectToTargetDevice && ConnectToCommissionerDevice
    case DeviceTooFar
    case FailedToStartScan
    case FailedToFlashBecauseOfTimeout
    case FailedToScanBecauseOfTimeout
    case FailedToConnect

    case CannotAddGatewayDeviceAsJoiner

    case UnableToDownloadFirmwareBinary

    //Can happen in any step, inform user about it and repeat the step
    case BluetoothDisabled
    case BluetoothConnectionDropped

    //Can happen in any step, when result != NONE and special case is not handled by onReply handler
    case BluetoothError
    case BluetoothTimeout

    //EnsureCommissionerNetworkMatches
    case CommissionerNetworkDoesNotMatch
    case WrongNetworkPassword
    case PasswordTooShort
    case WifiPasswordTooShort

    case SameDeviceScannedTwice
    case WrongDeviceType //temp error

    //EnsureHasInternetAccess
    case FailedToObtainIp
    case FailedToUpdateDeviceOS

    //GetNewDeviceName
    case UnableToJoinNetwork
    case UnableToJoinOldNetwork
    case UnableToRetrieveNetworks
    case UnableToLeaveNetwork
    case UnableToCreateNetwork
    case UnableToRenameDevice
    case NameTooShort

    case DeviceIsNotAllowedToJoinNetwork
    case DeviceIsUnableToFindNetworkToJoin
    case DeviceTimeoutWhileJoiningNetwork

    //CheckDeviceGotClaimed
    case DeviceConnectToCloudTimeout
    case DeviceGettingClaimedTimeout

    public var description: String {
        switch self {
                //these errors are handled instantly
            case .FailedToUpdateDeviceOS : return "There was an error while performing DeviceOS update."
            case .FailedToFlashBecauseOfTimeout : return "It seems that device has exited the listening mode. Please put it in listening mode again (blinking blue) and retry."

            case .UnableToDownloadFirmwareBinary : return "Failed to download firmware update. Please try again later."
            case .CannotAddGatewayDeviceAsJoiner : return "Support for adding multiple gateways to a single network is coming soon. Argons, Borons, and Xenons+Ethernet FeatherWings must be set up as a standalone device, or as the first gateway in a new mesh network."


            case .WrongNetworkPassword : return "Provided password is incorrect."
            case .WifiPasswordTooShort : return "Provided password is too short."
            case .PasswordTooShort : return "Network password has to be between 6 and 16 characters."
            case .IllegalOperation : return "Illegal operation."
            case .UnableToRenameDevice : return "Unable to rename device at this time. Please try again later."
            case .NameTooShort : return "Device name cannot be empty."

                //user facing errors
            case .UnableToLeaveNetwork : return "There was an error while removing device from mesh network on Particle Device Cloud."
            case .UnableToJoinNetwork : return "There was an error while adding device to mesh network on Particle Device Cloud."
            case .UnableToJoinOldNetwork : return "Network you are trying to join, was created locally with test version of the app. Please create new network."
            case .UnableToRetrieveNetworks : return "There was an error while accessing mesh network information on Particle Device Cloud."
            case .UnableToCreateNetwork : return "There was an error while registering new network with Particle Device Cloud."
            case .UnableToGenerateClaimCode : return "There was an error attempting to claim this device to your account."
            case .DeviceTooFar : return "Your mesh device is too far away from your phone. Please hold your phone closer and try again."
            case .FailedToStartScan : return "Bluetooth appears to be disabled on your phone. Please enable Bluetooth and try again."
            case .FailedToScanBecauseOfTimeout : return "Unable to find your mesh device. Make sure the mesh device’s LED is blinking blue and that it’s not connected to any other devices."
            case .FailedToConnect : return "You phone failed to connect to your mesh device. Please try again."
            case .BluetoothDisabled : return "Bluetooth appears to be disabled on your phone. Please enable Bluetooth and try again."
            case .BluetoothTimeout : return "Sending bluetooth message failed. Please try again."
            case .BluetoothError : return "Something went wrong with Bluetooth. Please restart the the setup process and try again."
            case .CommissionerNetworkDoesNotMatch : return "The assisting device is on a different mesh network than the one you are trying to join. Please make sure the devices are trying to use the same network."
            case .SameDeviceScannedTwice : return "This is the device that is being setup. Please scan the sticker of device that is on the mesh network you are trying to join."
            case .WrongDeviceType : return "This is not {{device}}. Please scan {{device}} sticker or restart the setup and choose different device type."
            case .FailedToObtainIp : return "Your device failed to obtain an IP address. Please make sure the ethernet cable is connected securely to the Ethernet FeatherWing."

            case .BluetoothConnectionDropped : return "The Bluetooth connection was dropped unexpectedly. Please restart the setup and try again."

            case .DeviceIsNotAllowedToJoinNetwork : return "Your device was unable to join the network (NOT_ALLOWED). Please press try again."
            case .DeviceIsUnableToFindNetworkToJoin : return "Your device was unable to join the network (NOT_FOUND). Please press try again."
            case .DeviceTimeoutWhileJoiningNetwork : return "Your device was unable to join the network (TIMEOUT). Please press try again."

            case .DeviceConnectToCloudTimeout : return "Your device could not connect to Device Cloud. Please try again."
            case .DeviceGettingClaimedTimeout : return "Your device failed to be claimed. Please try again."
        }
    }
}

enum MeshSetupErrorSeverity {
    case Error //can't continue at this point, but retrying might help
    case Fatal //can't continue and flow has to be restarted
}

internal struct MeshDevice {
    var type: ParticleDeviceType?
    var deviceId: String?
    var deviceICCID: String?
    var credentials: MeshSetupPeripheralCredentials?
    var name: String? //name stored in cloud (credentials has name of bluetooth network)

    var transceiver: MeshSetupProtocolTransceiver?

    //flags related to OTA Update
    var firmwareVersion: String?
    var ncpVersion: String?
    var ncpModuleVersion: Int?
    var supportsCompressedOTAUpdate: Bool?
    var nextFirmwareBinaryURL: String?
    var nextFirmwareBinaryFilePath: String?
    var firmwareFilesFlashed: Int?
    var firmwareUpdateProgress: Double?
    var enableEthernetFeature: Bool?

    var claimCode: String?
    var isClaimed: Bool?
    var isSetupDone: Bool?


    var activeInternetInterface: MeshSetupNetworkInterfaceType?
    var hasInternetAddress: Bool?

    var networkInterfaces: [MeshSetupNetworkInterfaceEntry]?
    var joinerCredentials: (eui64: String, password: String)?

    var meshNetworkInfo: MeshSetupNetworkInfo?

    var meshNetworks: [MeshSetupNetworkInfo]?
    var apiNetworks: [ParticleNetwork]?

    var wifiNetworks: [MeshSetupNewWifiNetworkInfo]?



    func hasActiveInternetInterface() -> Bool {
        return activeInternetInterface != nil
    }

    func getActiveNetworkInterfaceIdx() -> UInt32? {
        if let activeInterface = activeInternetInterface, let interfaces = networkInterfaces {
            for interface in interfaces {
                if interface.type == activeInterface {
                    return interface.index
                }
            }
        }
        return nil
    }
}

internal struct MeshSetupPeripheralCredentials {
    var name: String
    var mobileSecret: String
}

internal struct MeshSetupDataMatrix {
    var serialNumber: String
    var mobileSecret: String

    init?(dataMatrixString: String) {
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z0-9]{15})[ ]{1}([a-zA-Z0-9]{15})")
        let nsString = dataMatrixString as NSString
        let results = regex.matches(in: dataMatrixString, range: NSRange(location: 0, length: nsString.length))

        if (results.count > 0) {
            let arr = dataMatrixString.split(separator: " ")
            serialNumber = String(arr[0])//"12345678abcdefg"
            mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        } else {
            return nil
        }
    }
}