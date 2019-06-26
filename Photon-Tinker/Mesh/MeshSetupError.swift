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
            case .CriticalFlowError : return MeshSetupStrings.Error.CriticalFlowError.meshLocalized()
            case .SimBelongsToOtherAccount : return MeshSetupStrings.Error.SimBelongsToOtherAccount.meshLocalized()
            case .ExternalSimNotSupported : return MeshSetupStrings.Error.ExternalSimNotSupported.meshLocalized()
            case .StickerError : return MeshSetupStrings.Error.StickerError.meshLocalized()
            case .NetworkError : return MeshSetupStrings.Error.NetworkError.meshLocalized()
            case .InvalidDeviceState : return MeshSetupStrings.Error.InvalidDeviceState.meshLocalized()
            case .NameInUse : return MeshSetupStrings.Error.NameInUse.meshLocalized()
            case .FailedToObtainIpBoron : return MeshSetupStrings.Error.FailedToObtainIpBoron.meshLocalized()
            case .WrongTargetDeviceType : return MeshSetupStrings.Error.WrongTargetDeviceType.meshLocalized()
            case .WrongCommissionerDeviceType : return MeshSetupStrings.Error.WrongCommissionerDeviceType.meshLocalized()
            case .BoronModemError : return MeshSetupStrings.Error.BoronModemError.meshLocalized()
            case .FailedToChangeSimDataLimit : return MeshSetupStrings.Error.FailedToChangeSimDataLimit.meshLocalized()
            case .FailedToGetDeviceInfo : return MeshSetupStrings.Error.FailedToGetDeviceInfo.meshLocalized()


                //these errors are handled instantly
            case .FailedToUpdateDeviceOS : return MeshSetupStrings.Error.FailedToUpdateDeviceOS.meshLocalized()
            case .FailedToFlashBecauseOfTimeout : return MeshSetupStrings.Error.FailedToFlashBecauseOfTimeout.meshLocalized()
            case .UnableToDownloadFirmwareBinary : return MeshSetupStrings.Error.UnableToDownloadFirmwareBinary.meshLocalized()
            case .CannotAddGatewayDeviceAsJoiner : return MeshSetupStrings.Error.CannotAddGatewayDeviceAsJoiner.meshLocalized()
            case .WrongNetworkPassword : return MeshSetupStrings.Error.WrongNetworkPassword.meshLocalized()
            case .WifiPasswordTooShort : return MeshSetupStrings.Error.WifiPasswordTooShort.meshLocalized()
            case .PasswordTooShort : return MeshSetupStrings.Error.PasswordTooShort.meshLocalized()
            case .IllegalOperation : return MeshSetupStrings.Error.IllegalOperation.meshLocalized()
            case .UnableToRenameDevice : return MeshSetupStrings.Error.UnableToRenameDevice.meshLocalized()
            case .NameTooShort : return MeshSetupStrings.Error.NameTooShort.meshLocalized()
                //user facing errors
            case .FailedToActivateSim : return MeshSetupStrings.Error.FailedToActivateSim.meshLocalized()
            case .FailedToDeactivateSim : return MeshSetupStrings.Error.FailedToDeactivateSim.meshLocalized()

            case .CCMissing : return MeshSetupStrings.Error.CCMissing.meshLocalized()
            case .UnableToGetPricingInformation : return MeshSetupStrings.Error.UnableToGetPricingInformation.meshLocalized()
            case .UnableToGetSimStatus : return MeshSetupStrings.Error.UnableToGetSimStatus.meshLocalized()
            case .UnableToPublishDeviceSetupEvent : return MeshSetupStrings.Error.UnableToPublishDeviceSetupEvent.meshLocalized()
            case .UnableToLeaveNetwork : return MeshSetupStrings.Error.UnableToLeaveNetwork.meshLocalized()
            case .UnableToJoinNetwork : return MeshSetupStrings.Error.UnableToJoinNetwork.meshLocalized()
            case .UnableToJoinOldNetwork : return MeshSetupStrings.Error.UnableToJoinOldNetwork.meshLocalized()
            case .UnableToRetrieveNetworks : return MeshSetupStrings.Error.UnableToRetrieveNetworks.meshLocalized()
            case .UnableToCreateNetwork : return MeshSetupStrings.Error.UnableToCreateNetwork.meshLocalized()
            case .UnableToGenerateClaimCode : return MeshSetupStrings.Error.UnableToGenerateClaimCode.meshLocalized()
            case .DeviceTooFar : return MeshSetupStrings.Error.DeviceTooFar.meshLocalized()
            case .FailedToStartScan : return MeshSetupStrings.Error.FailedToStartScan.meshLocalized()
            case .FailedToScanBecauseOfTimeout : return MeshSetupStrings.Error.FailedToScanBecauseOfTimeout.meshLocalized()
            case .FailedToConnect : return MeshSetupStrings.Error.FailedToConnect.meshLocalized()
            case .BluetoothDisabled : return MeshSetupStrings.Error.BluetoothDisabled.meshLocalized()
            case .BluetoothTimeout : return MeshSetupStrings.Error.BluetoothTimeout.meshLocalized()
            case .BluetoothError : return MeshSetupStrings.Error.BluetoothError.meshLocalized()
            case .CommissionerNetworkDoesNotMatch : return MeshSetupStrings.Error.CommissionerNetworkDoesNotMatch.meshLocalized()
            case .SameDeviceScannedTwice : return MeshSetupStrings.Error.SameDeviceScannedTwice.meshLocalized()
            case .FailedToObtainIp : return MeshSetupStrings.Error.FailedToObtainIp.meshLocalized()
            case .BluetoothConnectionDropped : return MeshSetupStrings.Error.BluetoothConnectionDropped.meshLocalized()
            case .DeviceIsNotAllowedToJoinNetwork : return MeshSetupStrings.Error.DeviceIsNotAllowedToJoinNetwork.meshLocalized()
            case .DeviceIsUnableToFindNetworkToJoin : return MeshSetupStrings.Error.DeviceIsUnableToFindNetworkToJoin.meshLocalized()
            case .DeviceTimeoutWhileJoiningNetwork : return MeshSetupStrings.Error.DeviceTimeoutWhileJoiningNetwork.meshLocalized()
            case .DeviceConnectToCloudTimeout : return MeshSetupStrings.Error.DeviceConnectToCloudTimeout.meshLocalized()
            case .DeviceGettingClaimedTimeout : return MeshSetupStrings.Error.DeviceGettingClaimedTimeout.meshLocalized()
            case .ThisDeviceIsACommissioner : return MeshSetupStrings.Error.ThisDeviceIsACommissioner.meshLocalized()
        }
    }
}


