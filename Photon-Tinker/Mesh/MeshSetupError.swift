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

    case MeshNotSupported
    case CommissionerMeshNotSupported

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
            case .CriticalFlowError : return Gen3SetupStrings.Error.CriticalFlowError.gen3SetupLocalized()
            case .SimBelongsToOtherAccount : return Gen3SetupStrings.Error.SimBelongsToOtherAccount.gen3SetupLocalized()
            case .ExternalSimNotSupported : return Gen3SetupStrings.Error.ExternalSimNotSupported.gen3SetupLocalized()
            case .StickerError : return Gen3SetupStrings.Error.StickerError.gen3SetupLocalized()
            case .NetworkError : return Gen3SetupStrings.Error.NetworkError.gen3SetupLocalized()
            case .InvalidDeviceState : return Gen3SetupStrings.Error.InvalidDeviceState.gen3SetupLocalized()
            case .NameInUse : return Gen3SetupStrings.Error.NameInUse.gen3SetupLocalized()
            case .FailedToObtainIpBoron : return Gen3SetupStrings.Error.FailedToObtainIpBoron.gen3SetupLocalized()
            case .WrongTargetDeviceType : return Gen3SetupStrings.Error.WrongTargetDeviceType.gen3SetupLocalized()
            case .WrongCommissionerDeviceType : return Gen3SetupStrings.Error.WrongCommissionerDeviceType.gen3SetupLocalized()
            case .BoronModemError : return Gen3SetupStrings.Error.BoronModemError.gen3SetupLocalized()
            case .FailedToChangeSimDataLimit : return Gen3SetupStrings.Error.FailedToChangeSimDataLimit.gen3SetupLocalized()
            case .FailedToGetDeviceInfo : return Gen3SetupStrings.Error.FailedToGetDeviceInfo.gen3SetupLocalized()
            case .FailedToFlashBecauseOfTimeout : return Gen3SetupStrings.Error.FailedToFlashBecauseOfTimeout.gen3SetupLocalized()
            case .FailedToHandshakeBecauseOfTimeout : return Gen3SetupStrings.Error.FailedToHandshakeBecauseOfTimeout.gen3SetupLocalized()

            case .MeshNotSupported : return Gen3SetupStrings.Error.MeshNotSupported.gen3SetupLocalized()
            case .CommissionerMeshNotSupported : return Gen3SetupStrings.Error.CommissionerMeshNotSupported.gen3SetupLocalized()

                //these errors are handled instantly
            case .FailedToUpdateDeviceOS : return Gen3SetupStrings.Error.FailedToUpdateDeviceOS.gen3SetupLocalized()
            case .UnableToDownloadFirmwareBinary : return Gen3SetupStrings.Error.UnableToDownloadFirmwareBinary.gen3SetupLocalized()
            case .CannotAddGatewayDeviceAsJoiner : return Gen3SetupStrings.Error.CannotAddGatewayDeviceAsJoiner.gen3SetupLocalized()
            case .WrongNetworkPassword : return Gen3SetupStrings.Error.WrongNetworkPassword.gen3SetupLocalized()
            case .WifiPasswordTooShort : return Gen3SetupStrings.Error.WifiPasswordTooShort.gen3SetupLocalized()
            case .PasswordTooShort : return Gen3SetupStrings.Error.PasswordTooShort.gen3SetupLocalized()
            case .IllegalOperation : return Gen3SetupStrings.Error.IllegalOperation.gen3SetupLocalized()
            case .UnableToRenameDevice : return Gen3SetupStrings.Error.UnableToRenameDevice.gen3SetupLocalized()
            case .NameTooShort : return Gen3SetupStrings.Error.NameTooShort.gen3SetupLocalized()
                //user facing errors
            case .FailedToActivateSim : return Gen3SetupStrings.Error.FailedToActivateSim.gen3SetupLocalized()
            case .FailedToDeactivateSim : return Gen3SetupStrings.Error.FailedToDeactivateSim.gen3SetupLocalized()

            case .CCMissing : return Gen3SetupStrings.Error.CCMissing.gen3SetupLocalized()
            case .UnableToGetPricingInformation : return Gen3SetupStrings.Error.UnableToGetPricingInformation.gen3SetupLocalized()
            case .UnableToGetSimStatus : return Gen3SetupStrings.Error.UnableToGetSimStatus.gen3SetupLocalized()
            case .UnableToPublishDeviceSetupEvent : return Gen3SetupStrings.Error.UnableToPublishDeviceSetupEvent.gen3SetupLocalized()
            case .UnableToLeaveNetwork : return Gen3SetupStrings.Error.UnableToLeaveNetwork.gen3SetupLocalized()
            case .UnableToJoinNetwork : return Gen3SetupStrings.Error.UnableToJoinNetwork.gen3SetupLocalized()
            case .UnableToJoinOldNetwork : return Gen3SetupStrings.Error.UnableToJoinOldNetwork.gen3SetupLocalized()
            case .UnableToRetrieveNetworks : return Gen3SetupStrings.Error.UnableToRetrieveNetworks.gen3SetupLocalized()
            case .UnableToCreateNetwork : return Gen3SetupStrings.Error.UnableToCreateNetwork.gen3SetupLocalized()
            case .UnableToGenerateClaimCode : return Gen3SetupStrings.Error.UnableToGenerateClaimCode.gen3SetupLocalized()
            case .DeviceTooFar : return Gen3SetupStrings.Error.DeviceTooFar.gen3SetupLocalized()
            case .FailedToStartScan : return Gen3SetupStrings.Error.FailedToStartScan.gen3SetupLocalized()
            case .FailedToScanBecauseOfTimeout : return Gen3SetupStrings.Error.FailedToScanBecauseOfTimeout.gen3SetupLocalized()
            case .FailedToConnect : return Gen3SetupStrings.Error.FailedToConnect.gen3SetupLocalized()
            case .BluetoothDisabled : return Gen3SetupStrings.Error.BluetoothDisabled.gen3SetupLocalized()
            case .BluetoothTimeout : return Gen3SetupStrings.Error.BluetoothTimeout.gen3SetupLocalized()
            case .BluetoothError : return Gen3SetupStrings.Error.BluetoothError.gen3SetupLocalized()
            case .CommissionerNetworkDoesNotMatch : return Gen3SetupStrings.Error.CommissionerNetworkDoesNotMatch.gen3SetupLocalized()
            case .SameDeviceScannedTwice : return Gen3SetupStrings.Error.SameDeviceScannedTwice.gen3SetupLocalized()
            case .FailedToObtainIp : return Gen3SetupStrings.Error.FailedToObtainIp.gen3SetupLocalized()
            case .BluetoothConnectionDropped : return Gen3SetupStrings.Error.BluetoothConnectionDropped.gen3SetupLocalized()
            case .DeviceIsNotAllowedToJoinNetwork : return Gen3SetupStrings.Error.DeviceIsNotAllowedToJoinNetwork.gen3SetupLocalized()
            case .DeviceIsUnableToFindNetworkToJoin : return Gen3SetupStrings.Error.DeviceIsUnableToFindNetworkToJoin.gen3SetupLocalized()
            case .DeviceTimeoutWhileJoiningNetwork : return Gen3SetupStrings.Error.DeviceTimeoutWhileJoiningNetwork.gen3SetupLocalized()
            case .DeviceConnectToCloudTimeout : return Gen3SetupStrings.Error.DeviceConnectToCloudTimeout.gen3SetupLocalized()
            case .DeviceGettingClaimedTimeout : return Gen3SetupStrings.Error.DeviceGettingClaimedTimeout.gen3SetupLocalized()
            case .ThisDeviceIsACommissioner : return Gen3SetupStrings.Error.ThisDeviceIsACommissioner.gen3SetupLocalized()
        }
    }
}


