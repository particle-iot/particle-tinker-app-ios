//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

enum MeshSetupErrorSeverity {
    case Error //can't continue at this point, but retrying might help
    case Fatal //can't continue and flow has to be restarted
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
    case WrongTargetDeviceType
    case WrongCommissionerDeviceType

    //EnsureHasInternetAccess
    case FailedToObtainIp
    case FailedToObtainIpBoron
    case FailedToUpdateDeviceOS

    case InvalidDeviceState

    //GetNewDeviceName
    case SimBelongsToOtherAccount
    case CriticalFlowError
    case ExternalSimNotSupported
    case StickerError
    case NetworkError
    case FailedToActivateSim
    case CCMissing
    case UnableToGetPricingInformation
    case UnableToPublishDeviceSetupEvent
    case UnableToGetSimStatus
    case UnableToJoinNetwork
    case UnableToJoinOldNetwork
    case UnableToRetrieveNetworks
    case UnableToLeaveNetwork
    case UnableToCreateNetwork
    case UnableToRenameDevice
    case NameTooShort
    case BoronModemError
    case NameInUse

    case DeviceIsNotAllowedToJoinNetwork
    case DeviceIsUnableToFindNetworkToJoin
    case DeviceTimeoutWhileJoiningNetwork
    case ThisDeviceIsACommissioner

    //CheckDeviceGotClaimed
    case DeviceConnectToCloudTimeout
    case DeviceGettingClaimedTimeout


    public var description: String {
        switch self {
                //unproofread
            case .CriticalFlowError : return "There was a problem with the setup. Please contact support with the latest device log to help us fix it as soon as possible."
            case .SimBelongsToOtherAccount : return "The SIM you are trying to interact with is owned by a different user account."
            case .ExternalSimNotSupported : return "We have detected that you are using external sim card. Use the internal SIM to complete setup. You may use an external SIM after setup is complete."
            case .StickerError : return "There is a problem with the sticker on your device. Please contact support for a solution."
            case .NetworkError : return "There was a network error communicating to Particle Device Cloud."
            case .InvalidDeviceState : return "Device is in invalid state, please reset the device and start again."
            case .NameInUse : return "You already own a network with this name. Please use different name."
            case .FailedToObtainIpBoron : return "Your device is taking longer than expected to connect to the Internet. If you are setting up a Boron 2/3G, it may take up to 5 minutes to establish a connection with the cellular tower in your area."
            case .WrongTargetDeviceType : return "This is not valid device sticker. Please scan 3rd generation device sticker."
            case .WrongCommissionerDeviceType : return "This is not valid device sticker. Please scan 3rd generation device sticker."
            case .BoronModemError : return "There was an error while accessing modem on your device. Device is now rebooting the modem in attempt to recover. Give it a second and try again. If this error persists try rebooting your device manually and restart the setup."

                //these errors are handled instantly
            case .FailedToUpdateDeviceOS : return "There was an error while performing a Device OS update."
            case .FailedToFlashBecauseOfTimeout : return "It seems that your device has exited listening mode. Please put your device in listening mode (blinking blue) and retry."
            case .UnableToDownloadFirmwareBinary : return "Failed to download the firmware update. Please try again later."
            case .CannotAddGatewayDeviceAsJoiner : return "Support for adding multiple gateways to a single network is coming soon. Argons, Borons, and Xenons with Ethernet FeatherWings, must be set up as a standalone device or as the first gateway in a new mesh network."
            case .WrongNetworkPassword : return "The password you entered is incorrect."
            case .WifiPasswordTooShort : return "The password you entered is too short."
            case .PasswordTooShort : return "Your network password must be between 6 and 16 characters."
            case .IllegalOperation : return "Illegal operation."
            case .UnableToRenameDevice : return "Unable to rename your device at this time. Please try again later."
            case .NameTooShort : return "Your device name cannot be empty."
                //user facing errors
            case .FailedToActivateSim : return "SIM activation is taking longer than expected. Please retry your SIM activation. If you have retried multiple times, please contact support."
            case .CCMissing : return "You need to add a credit card to your account to continue. Please visit https://console.particle.io/billing/edit-card to add a card and return here when you're done."
            case .UnableToGetPricingInformation : return "There was an error while retrieving pricing information. Please try again."
            case .UnableToGetSimStatus : return "There was an error while reading internal SIM card status. Please try again."
            case .UnableToPublishDeviceSetupEvent : return "There was an error while notifying the Particle Device Cloud about successful device setup. Please try again."
            case .UnableToLeaveNetwork : return "There was an error while removing your device from the mesh network on Particle Device Cloud."
            case .UnableToJoinNetwork : return "There was an error while adding your device to mesh network on Particle Device Cloud."
            case .UnableToJoinOldNetwork : return "The network you are trying to join was created locally with test version of the app. Please create new network."
            case .UnableToRetrieveNetworks : return "There was an error while accessing your mesh network information on Particle Device Cloud."
            case .UnableToCreateNetwork : return "There was an error while registering your new network with Particle Device Cloud."
            case .UnableToGenerateClaimCode : return "There was an error attempting to claim this device to your account."
            case .DeviceTooFar : return "Your mesh device is too far away from your phone. Please hold your phone closer and try again."
            case .FailedToStartScan : return "Bluetooth appears to be disabled on your phone. Please enable Bluetooth and try again."
            case .FailedToScanBecauseOfTimeout : return "Unable to find your mesh device. Make sure the mesh device's LED is blinking blue and that it's not connected to any other devices."
            case .FailedToConnect : return "You phone failed to connect to your mesh device. Please try again."
            case .BluetoothDisabled : return "Bluetooth appears to be disabled on your phone. Please enable Bluetooth and try again."
            case .BluetoothTimeout : return "Sending Bluetooth messages failed. Please try again."
            case .BluetoothError : return "Something went wrong with Bluetooth. Please restart the set up process and try again."
            case .CommissionerNetworkDoesNotMatch : return "The assisting device is on a different mesh network than the one you are trying to join. Please make sure the devices are trying to use the same network."
            case .SameDeviceScannedTwice : return "This is the device that is being setup. Please scan the sticker of device that is on the mesh network you are trying to join."
            case .FailedToObtainIp : return "Your device failed to obtain an IP address. Please make sure your device has internet access."
            case .BluetoothConnectionDropped : return "The Bluetooth connection was dropped unexpectedly. Please restart the set up and try again."
            case .DeviceIsNotAllowedToJoinNetwork : return "Your device was unable to join the network (NOT_ALLOWED). Please press try again."
            case .DeviceIsUnableToFindNetworkToJoin : return "Your device was unable to join the network (NOT_FOUND). Please press try again."
            case .DeviceTimeoutWhileJoiningNetwork : return "Your device was unable to join the network (TIMEOUT). Please press try again."
            case .DeviceConnectToCloudTimeout : return "Your device could not connect to Device Cloud. Please try again."
            case .DeviceGettingClaimedTimeout : return "Your device failed to be claimed. Please try again."
            case .ThisDeviceIsACommissioner : return "This device now acts as commissioner. Please restart the setup if you want to set it up again."
        }
    }
}


