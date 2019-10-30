//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 Particle. All rights reserved.
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
    case FailedToHandshakeBecauseOfTimeout
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
    case FailedToGetDeviceInfo

    case InvalidDeviceState

    //GetNewDeviceName
    case SimBelongsToOtherAccount
    case CriticalFlowError
    case ExternalSimNotSupported
    case StickerError
    case NetworkError
    case FailedToActivateSim
    case FailedToDeactivateSim
    case FailedToChangeSimDataLimit
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
            case .CriticalFlowError : return MeshStrings.Error.CriticalFlowError.meshLocalized()
            case .SimBelongsToOtherAccount : return MeshStrings.Error.SimBelongsToOtherAccount.meshLocalized()
            case .ExternalSimNotSupported : return MeshStrings.Error.ExternalSimNotSupported.meshLocalized()
            case .StickerError : return MeshStrings.Error.StickerError.meshLocalized()
            case .NetworkError : return MeshStrings.Error.NetworkError.meshLocalized()
            case .InvalidDeviceState : return MeshStrings.Error.InvalidDeviceState.meshLocalized()
            case .NameInUse : return MeshStrings.Error.NameInUse.meshLocalized()
            case .FailedToObtainIpBoron : return MeshStrings.Error.FailedToObtainIpBoron.meshLocalized()
            case .WrongTargetDeviceType : return MeshStrings.Error.WrongTargetDeviceType.meshLocalized()
            case .WrongCommissionerDeviceType : return MeshStrings.Error.WrongCommissionerDeviceType.meshLocalized()
            case .BoronModemError : return MeshStrings.Error.BoronModemError.meshLocalized()
            case .FailedToChangeSimDataLimit : return MeshStrings.Error.FailedToChangeSimDataLimit.meshLocalized()
            case .FailedToGetDeviceInfo : return MeshStrings.Error.FailedToGetDeviceInfo.meshLocalized()
            case .FailedToFlashBecauseOfTimeout : return MeshStrings.Error.FailedToFlashBecauseOfTimeout.meshLocalized()
            case .FailedToHandshakeBecauseOfTimeout : return MeshStrings.Error.FailedToHandshakeBecauseOfTimeout.meshLocalized()


                //these errors are handled instantly
            case .FailedToUpdateDeviceOS : return MeshStrings.Error.FailedToUpdateDeviceOS.meshLocalized()
            case .UnableToDownloadFirmwareBinary : return MeshStrings.Error.UnableToDownloadFirmwareBinary.meshLocalized()
            case .CannotAddGatewayDeviceAsJoiner : return MeshStrings.Error.CannotAddGatewayDeviceAsJoiner.meshLocalized()
            case .WrongNetworkPassword : return MeshStrings.Error.WrongNetworkPassword.meshLocalized()
            case .WifiPasswordTooShort : return MeshStrings.Error.WifiPasswordTooShort.meshLocalized()
            case .PasswordTooShort : return MeshStrings.Error.PasswordTooShort.meshLocalized()
            case .IllegalOperation : return MeshStrings.Error.IllegalOperation.meshLocalized()
            case .UnableToRenameDevice : return MeshStrings.Error.UnableToRenameDevice.meshLocalized()
            case .NameTooShort : return MeshStrings.Error.NameTooShort.meshLocalized()
                //user facing errors
            case .FailedToActivateSim : return MeshStrings.Error.FailedToActivateSim.meshLocalized()
            case .FailedToDeactivateSim : return MeshStrings.Error.FailedToDeactivateSim.meshLocalized()

            case .CCMissing : return MeshStrings.Error.CCMissing.meshLocalized()
            case .UnableToGetPricingInformation : return MeshStrings.Error.UnableToGetPricingInformation.meshLocalized()
            case .UnableToGetSimStatus : return MeshStrings.Error.UnableToGetSimStatus.meshLocalized()
            case .UnableToPublishDeviceSetupEvent : return MeshStrings.Error.UnableToPublishDeviceSetupEvent.meshLocalized()
            case .UnableToLeaveNetwork : return MeshStrings.Error.UnableToLeaveNetwork.meshLocalized()
            case .UnableToJoinNetwork : return MeshStrings.Error.UnableToJoinNetwork.meshLocalized()
            case .UnableToJoinOldNetwork : return MeshStrings.Error.UnableToJoinOldNetwork.meshLocalized()
            case .UnableToRetrieveNetworks : return MeshStrings.Error.UnableToRetrieveNetworks.meshLocalized()
            case .UnableToCreateNetwork : return MeshStrings.Error.UnableToCreateNetwork.meshLocalized()
            case .UnableToGenerateClaimCode : return MeshStrings.Error.UnableToGenerateClaimCode.meshLocalized()
            case .DeviceTooFar : return MeshStrings.Error.DeviceTooFar.meshLocalized()
            case .FailedToStartScan : return MeshStrings.Error.FailedToStartScan.meshLocalized()
            case .FailedToScanBecauseOfTimeout : return MeshStrings.Error.FailedToScanBecauseOfTimeout.meshLocalized()
            case .FailedToConnect : return MeshStrings.Error.FailedToConnect.meshLocalized()
            case .BluetoothDisabled : return MeshStrings.Error.BluetoothDisabled.meshLocalized()
            case .BluetoothTimeout : return MeshStrings.Error.BluetoothTimeout.meshLocalized()
            case .BluetoothError : return MeshStrings.Error.BluetoothError.meshLocalized()
            case .CommissionerNetworkDoesNotMatch : return MeshStrings.Error.CommissionerNetworkDoesNotMatch.meshLocalized()
            case .SameDeviceScannedTwice : return MeshStrings.Error.SameDeviceScannedTwice.meshLocalized()
            case .FailedToObtainIp : return MeshStrings.Error.FailedToObtainIp.meshLocalized()
            case .BluetoothConnectionDropped : return MeshStrings.Error.BluetoothConnectionDropped.meshLocalized()
            case .DeviceIsNotAllowedToJoinNetwork : return MeshStrings.Error.DeviceIsNotAllowedToJoinNetwork.meshLocalized()
            case .DeviceIsUnableToFindNetworkToJoin : return MeshStrings.Error.DeviceIsUnableToFindNetworkToJoin.meshLocalized()
            case .DeviceTimeoutWhileJoiningNetwork : return MeshStrings.Error.DeviceTimeoutWhileJoiningNetwork.meshLocalized()
            case .DeviceConnectToCloudTimeout : return MeshStrings.Error.DeviceConnectToCloudTimeout.meshLocalized()
            case .DeviceGettingClaimedTimeout : return MeshStrings.Error.DeviceGettingClaimedTimeout.meshLocalized()
            case .ThisDeviceIsACommissioner : return MeshStrings.Error.ThisDeviceIsACommissioner.meshLocalized()
        }
    }
}


