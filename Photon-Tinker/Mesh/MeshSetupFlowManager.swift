////
//// Created by Raimundas Sakalauskas on 9/20/18.
//// Copyright © 2018 Particle. All rights reserved.
////
//
//import Foundation
//import Crashlytics
//
//
//class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate {

//    //MARK: Helpers
//    private func targetDeviceLeaveMeshNetwork(reloadAPINetworks: Bool) {
//        self.targetDevice.transceiver!.sendLeaveNetwork { result in
//            self.log("targetDevice.didReceiveLeaveNetworkReply: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.targetDevice.meshNetworkInfo = nil
//                if (reloadAPINetworks) {
//                    self.getAPINetworks {
//                        self.stepComplete(.EnsureTargetDeviceIsNotOnMeshNetwork)
//                    }
//                } else {
//                    self.stepComplete(.EnsureTargetDeviceIsNotOnMeshNetwork)
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func removeRepeatedMeshNetworks(_ networks: [MeshSetupNetworkInfo]) -> [MeshSetupNetworkInfo] {
//        var meshNetworkIds:Set<String> = []
//        var filtered:[MeshSetupNetworkInfo] = []
//
//        for network in networks {
//            if (!meshNetworkIds.contains(network.extPanID)) {
//                meshNetworkIds.insert(network.extPanID)
//                filtered.append(network)
//            }
//        }
//
//        return filtered
//    }
//
//
//    private func removeRepeatedWifiNetworks(_ networks: [MeshSetupNewWifiNetworkInfo]) -> [MeshSetupNewWifiNetworkInfo] {
//        var wifiNetworkIds:Set<String> = []
//        var filtered:[MeshSetupNewWifiNetworkInfo] = []
//
//        for network in networks {
//            if (!wifiNetworkIds.contains(network.ssid)) {
//                wifiNetworkIds.insert(network.ssid)
//                filtered.append(network)
//            }
//        }
//
//        return filtered
//    }
//
//    //MARK: Input validators
//    private func validateNetworkPassword(_ password: String) -> Bool {
//        return password.count >= 6
//    }
//
//    private func validateWifiNetworkPassword(_ password: String) -> Bool {
//        return password.count >= 5
//    }
//
//    private func validateNetworkName(_ networkName: String) -> Bool {
//        //ensure proper length
//        if (networkName.count == 0) || (networkName.count > 16) {
//            return false
//        }
//
//        //ensure no illegal characters
//        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z0-9_\\-]+")
//        let matches = regex.matches(in: networkName, options: [], range: NSRange(location: 0, length: networkName.count))
//        return matches.count == 0
//    }
//
//    private func validateDeviceName(_ name: String) -> Bool {
//        return name.count > 0
//    }
//
//
//    //MARK: Error Handling
//    private func handleBluetoothErrorResult(_ result: ControlReplyErrorType) {
//        if (self.canceled) {
//            return
//        }
//
//        if (result == .TIMEOUT && !self.bluetoothReady) {
//            self.fail(withReason: .BluetoothDisabled)
//            return
//        } else if (result == .TIMEOUT) {
//            self.fail(withReason: .BluetoothTimeout)
//            return
//        } else if (result == .INVALID_STATE) {
//            self.fail(withReason: .InvalidDeviceState, severity: .Fatal)
//        } else {
//            self.fail(withReason: .BluetoothError)
//            return
//        }
//    }
//
//
////}
//
////extension MeshSetupFlowManager {
//
//    //MARK: GetUserWifiNetworkSelection
//    private func stepGetUserWifiNetworkSelection() {
//        self.delegate.meshSetupDidEnterState(state: .TargetDeviceScanningForWifiNetworks)
//        self.scanWifiNetworks()
//    }
//
//    private func scanWifiNetworks() {
//        self.targetDevice.transceiver!.sendScanWifiNetworks { result, networks in
//            self.log("sendScanWifiNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")
//
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.targetDevice.wifiNetworks = self.removeRepeatedWifiNetworks(networks!)
//                self.getUserWifiNetworkSelection()
//            } else {
//                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
//                self.targetDevice.wifiNetworks = []
//                self.getUserWifiNetworkSelection()
//            }
//        }
//    }
//
//    func rescanWifiNetworks() -> MeshSetupFlowError? {
//        //only allow to rescan if current step asks for it and transceiver is free to be used
//        guard let isBusy = targetDevice.transceiver?.isBusy, isBusy == false else {
//            return .IllegalOperation
//        }
//
//        if (self.currentCommand == .GetUserWifiNetworkSelection) {
//            self.scanWifiNetworks()
//        } else {
//            return .IllegalOperation
//        }
//
//        return nil
//    }
//
//
//    private func getUserWifiNetworkSelection() {
//        self.delegate.meshSetupDidRequestToSelectWifiNetwork(availableNetworks: self.targetDevice.wifiNetworks!)
//    }
//
//    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError? {
//        guard currentCommand == .GetUserWifiNetworkSelection else {
//            return .IllegalOperation
//        }
//
//        self.selectedWifiNetworkInfo = selectedNetwork
//        self.log("self.selectedWifiNetworkInfo: \(self.selectedWifiNetworkInfo)")
//        self.stepComplete(.GetUserWifiNetworkSelection)
//
//        return nil
//    }
//
//

//
//
//    //MARK: GetUserNetworkSelection
//    private func stepGetUserNetworkSelection() {
//        //adding more devices to same network
//        if (self.selectedNetworkMeshInfo != nil) {
//            self.stepComplete(.GetUserNetworkSelection)
//            return
//        }
//
//        self.delegate.meshSetupDidEnterState(state: .TargetDeviceScanningForNetworks)
//
//        self.scanNetworks {
//            self.getUserNetworkSelection()
//        }
//    }
//
//    private func getUserNetworkSelection() {
//        var networks = [String: MeshSetupNetworkCellInfo]()
//
//        for network in self.targetDevice.meshNetworks! {
//            networks[network.extPanID] = MeshSetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
//        }
//
//        for apiNetwork in self.apiNetworks! {
//            if let xpanId = apiNetwork.xpanId, var meshNetwork = networks[xpanId] {
//                meshNetwork.userOwned = true
//                meshNetwork.deviceCount = apiNetwork.deviceCount
//                networks[xpanId] = meshNetwork
//            }
//        }
//
//        self.delegate.meshSetupDidRequestToSelectNetwork(availableNetworks: Array(networks.values))
//    }
//
//    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError? {
//        guard currentCommand == .GetUserNetworkSelection else {
//            return .IllegalOperation
//        }
//
//        self.selectedNetworkMeshInfo = nil
//        for network in self.targetDevice.meshNetworks! {
//            if network.extPanID == selectedNetworkExtPanID {
//                self.selectedNetworkMeshInfo = network
//                break
//            }
//        }
//
//        self.log("self.selectedNetworkMeshInfo: \(self.selectedNetworkMeshInfo)")
//        self.stepComplete(.GetUserNetworkSelection)
//
//        return nil
//    }
//
//

//
//
//    //MARK: Common for network scan
//    private func scanNetworks(onComplete: @escaping () -> ()) {
//        self.targetDevice.transceiver!.sendScanNetworks { result, networks in
//            self.log("sendScanNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.targetDevice.meshNetworks = self.removeRepeatedMeshNetworks(networks!)
//                onComplete()
//            } else {
//                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
//                self.targetDevice.meshNetworks = []
//                onComplete()
//                //self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    func rescanNetworks() -> MeshSetupFlowError? {
//        //only allow to rescan if current step asks for it and transceiver is free to be used
//        guard let isBusy = targetDevice.transceiver?.isBusy, isBusy == false else {
//            return .IllegalOperation
//        }
//
//        if (self.currentCommand == .GetUserNetworkSelection) {
//            self.scanNetworks {
//                self.getUserNetworkSelection()
//            }
//        } else if (self.currentCommand == .OfferSelectOrCreateNetwork) {
//            self.scanNetworks {
//                self.getUserOptionalNetworkSelection()
//            }
//        } else {
//            return .IllegalOperation
//        }
//
//        return nil
//    }
//
//
//
//    //MARK: GetCommissionerDeviceInfo
//    private func stepGetCommissionerDeviceInfo() {
//        //adding more devices to same network
//        if (self.commissionerDevice?.credentials != nil) {
//            //we need to put the commissioner into listening mode by sending the command
//            self.commissionerDevice!.transceiver!.sendStarListening { result in
//                self.log("commissionerDevice.sendStarListening: \(result.description())")
//                if (self.canceled) {
//                    return
//                }
//                if (result == .NONE) {
//                    self.stepComplete(.GetCommissionerDeviceInfo)
//                } else {
//                    self.handleBluetoothErrorResult(result)
//                }
//            }
//            return
//        }
//
//        self.delegate.meshSetupDidRequestCommissionerDeviceInfo()
//    }
//
//    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
//        guard currentCommand == .GetCommissionerDeviceInfo else {
//            return .IllegalOperation
//        }
//
//        self.commissionerDevice = MeshDevice()
//
//        self.log("dataMatrix: \(dataMatrix)")
//        self.commissionerDevice!.type = dataMatrix.type
//        self.log("self.commissionerDevice.type?.description = \(self.commissionerDevice!.type?.description as Optional)")
//        self.commissionerDevice!.credentials = MeshSetupPeripheralCredentials(name: self.commissionerDevice!.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)
//
//        if (self.commissionerDevice?.credentials?.name == self.targetDevice.credentials?.name) {
//            self.commissionerDevice = nil
//            return .SameDeviceScannedTwice
//        }
//
//        self.stepComplete(.GetCommissionerDeviceInfo)
//
//        return nil
//    }
//
//
//
//    //MARK: EnsureCommissionerNetworkMatches
//    private func stepEnsureCommissionerNetworkMatches() {
//        self.commissionerDevice!.transceiver!.sendGetNetworkInfo { result, networkInfo in
//            self.log("commissionerDevice.sendGetNetworkInfo: \(result.description()), networkInfo: \(networkInfo as Optional)")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NOT_FOUND) {
//                self.commissionerDevice!.meshNetworkInfo = nil
//            } else if (result == .NONE) {
//                self.commissionerDevice!.meshNetworkInfo = networkInfo
//            } else {
//                self.handleBluetoothErrorResult(result)
//                return
//            }
//
//            if (self.selectedNetworkMeshInfo?.extPanID == self.commissionerDevice!.meshNetworkInfo?.extPanID) {
//                self.selectedNetworkMeshInfo = self.commissionerDevice!.meshNetworkInfo
//                self.targetDevice.meshNetworkInfo = self.commissionerDevice!.meshNetworkInfo
//
//                if let networkId = self.targetDevice.meshNetworkInfo?.networkID, networkId.count > 0 {
//                    self.stepComplete(.EnsureCommissionerNetworkMatches)
//                } else {
//                    self.fail(withReason: .UnableToJoinOldNetwork, severity: .Fatal)
//                    return
//                }
//            } else {
//                //drop connection with current peripheral
//                let connection = self.commissionerDevice!.transceiver!.connection
//                self.commissionerDevice!.transceiver = nil
//                self.commissionerDevice = nil
//                self.bluetoothManager.dropConnection(with: connection)
//
//
//                self.currentStep = self.currentFlow.index(of: .GetCommissionerDeviceInfo)!
//                self.pause = false
//
//                self.fail(withReason: .CommissionerNetworkDoesNotMatch)
//            }
//        }
//    }
//
//
//
//    //MARK: EnsureCorrectSelectedNetworkPassword
//    private func stepEnsureCorrectSelectedNetworkPassword() {
//        if (self.selectedNetworkPassword != nil) {
//            self.stepComplete(.EnsureCorrectSelectedNetworkPassword)
//            return
//        }
//
//        self.delegate.meshSetupDidRequestToEnterSelectedNetworkPassword()
//    }
//
//    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
//        guard currentCommand == .EnsureCorrectSelectedNetworkPassword else {
//            onComplete(.IllegalOperation)
//            return
//        }
//
//        guard self.validateNetworkPassword(password) else {
//            onComplete(.PasswordTooShort)
//            return
//        }
//
//        /// NOT_FOUND: The device is not a member of a network
//        /// NOT_ALLOWED: Invalid commissioning credential
//        self.commissionerDevice!.transceiver!.sendAuth(password: password) { result in
//            if (self.canceled) {
//                return
//            }
//            self.log("trying password: \(password)")
//
//            self.log("commissionerDevice.sendAuth: \(result.description())")
//            if (result == .NONE) {
//                self.log("password set: \(password)")
//                self.selectedNetworkPassword = password
//
//                onComplete(nil)
//                self.stepComplete(.EnsureCorrectSelectedNetworkPassword)
//            } else if (result == .NOT_ALLOWED) {
//                onComplete(.WrongNetworkPassword)
//            } else {
//                onComplete(.BluetoothTimeout)
//            }
//        }
//    }
//
//
//
//
//    //MARK: EnsureCorrectSelectedWifiNetworkPassword
//    private func stepEnsureCorrectSelectedWifiNetworkPassword() {
//        if self.selectedWifiNetworkInfo!.security == .noSecurity {
//            setSelectedWifiNetworkPassword("") { error in
//                self.log("WIFI with no password error: \(error)")
//            }
//            return
//        }
//        self.delegate.meshSetupDidRequestToEnterSelectedWifiNetworkPassword()
//    }
//
//    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
//        guard currentCommand == .EnsureCorrectSelectedWifiNetworkPassword else {
//            onComplete(.IllegalOperation)
//            return
//        }
//
//        guard self.validateWifiNetworkPassword(password) || (self.selectedWifiNetworkInfo!.security == .noSecurity) else {
//            onComplete(.WifiPasswordTooShort)
//            return
//        }
//
//        self.log("trying password: \(password)")
//        self.targetDevice!.transceiver?.sendJoinNewWifiNetwork(network: self.selectedWifiNetworkInfo!, password: password) {
//            result in
//
//            if (self.canceled) {
//                return
//            }
//
//            self.log("targetDevice.sendJoinNewWifiNetwork: \(result.description())")
//            if (self.selectedWifiNetworkInfo!.security == .noSecurity) {
//                if (result == .NONE) {
//                    onComplete(nil)
//                    self.stepComplete(.EnsureCorrectSelectedWifiNetworkPassword)
//                } else {
//                    onComplete(nil)
//                    self.handleBluetoothErrorResult(result)
//                }
//            } else {
//                if (result == .NONE) {
//                    onComplete(nil)
//                    self.stepComplete(.EnsureCorrectSelectedWifiNetworkPassword)
//                } else if (result == .NOT_FOUND) {
//                    onComplete(.WrongNetworkPassword)
//                } else {
//                    onComplete(.BluetoothTimeout)
//                }
//            }
//        }
//    }
//
//
//
//
//    //MARK: JoinSelectedNetwork
//    private func stepJoinSelectedNetwork() {
//        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStarted)
//        /// NOT_ALLOWED: The client is not authenticated
//        self.commissionerDevice!.transceiver!.sendStartCommissioner { result in
//            self.log("commissionerDevice.sendStartCommissioner: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if result == .NONE {
//                self.prepareJoiner()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func prepareJoiner() {
//        /// ALREADY_EXIST: The device is already a member of a network
//        /// NOT_ALLOWED: The client is not authenticated
//        self.targetDevice.transceiver!.sendPrepareJoiner(networkInfo: self.selectedNetworkMeshInfo!) { result, eui64, password in
//            self.log("targetDevice.sendPrepareJoiner sent networkInfo: \(self.selectedNetworkMeshInfo!)")
//            if (self.canceled) {
//                return
//            }
//            self.log("targetDevice.sendPrepareJoiner: \(result.description())")
//            if (result == .NONE) {
//                self.targetDevice.joinerCredentials = (eui64: eui64!, password: password!)
//                self.addJoiner()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func addJoiner() {
//        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStep1Done)
//        /// NO_MEMORY: No memory available to add the joiner
//        /// INVALID_STATE: The commissioner role is not started
//        /// NOT_ALLOWED: The client is not authenticated
//        self.commissionerDevice!.transceiver!.sendAddJoiner(eui64: self.targetDevice.joinerCredentials!.eui64, password: self.targetDevice.joinerCredentials!.password) { result in
//            self.log("commissionerDevice.sendAddJoiner: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.log("Delaying call to joinNetwork")
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
//                    if (self.canceled) {
//                        return
//                    }
//
//                    self.joinNetwork()
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func joinNetwork() {
//        self.log("Sending join network")
//        /// NOT_FOUND: No joinable network was found
//        /// TIMEOUT: The join process timed out
//        /// NOT_ALLOWED: Invalid security credentials
//        self.targetDevice.transceiver!.sendJoinNetwork { result in
//            self.log("targetDevice.sendJoinNetwork: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//
//            var failureReason: MeshSetupFlowError? = nil
//
//            if (result == .NONE) {
//                self.stepComplete(.JoinSelectedNetwork)
//            } else if (result == .NOT_ALLOWED) {
//                failureReason = .DeviceIsNotAllowedToJoinNetwork
//            } else if (result == .NOT_FOUND) {
//                failureReason = .DeviceIsUnableToFindNetworkToJoin
//            } else if (result == .TIMEOUT) {
//                failureReason = .DeviceTimeoutWhileJoiningNetwork
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//
//
//            if let reason = failureReason {
//                let recoveryLeaveNetwork = {
//                    self.targetDevice.transceiver!.sendLeaveNetwork() { result in
//                        self.log("targetDevice.sendLeaveNetwork: \(result.description())")
//                        if (self.canceled) {
//                            return
//                        }
//
//                        self.fail(withReason: reason)
//                        return
//                    }
//                }
//
//                self.commissionerDevice!.transceiver!.sendStopCommissioner { result in
//                    self.log("commissionerDevice.sendStopCommissioner: \(result.description())")
//                    if (self.canceled) {
//                        return
//                    }
//
//                    if (result == .NONE) {
//                        recoveryLeaveNetwork()
//                    } else {
//                        //if there's one more error here, do not display message cause that
//                        //most likely won't be handeled properly anyway
//                        self.fail(withReason: reason)
//                        return
//                    }
//                }
//            }
//         }
//    }
//
//
//    //MARK: FinishJoinNetwork
//    private func stepFinishJoinSelectedNetwork() {
//        self.joinNetworkInAPI()
//    }
//
//    private func joinNetworkInAPI() {
//        ParticleCloud.sharedInstance().addDevice(self.targetDevice.deviceId!, toNetwork: self.targetDevice.meshNetworkInfo!.networkID) {
//            error in
//
//            if (self.canceled) {
//                return
//            }
//
//            self.log("addDevice error: \(error as Optional)")
//            guard error == nil else {
//                self.fail(withReason: .UnableToJoinNetwork, nsError: error)
//                return
//            }
//
//            self.stopCommissioner()
//        }
//    }
//
//    private func stopCommissioner() {
//        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStep2Done)
//        /// NOT_ALLOWED: The client is not authenticated
//        self.commissionerDevice!.transceiver!.sendStopCommissioner { result in
//            self.log("commissionerDevice.sendStopCommissioner: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.setTargetDeviceSetupDone {
//                    self.stopCommissionerListening()
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//         }
//    }
//
//    private func setTargetDeviceSetupDone(onComplete: @escaping () -> ()) {
//        self.targetDevice.transceiver!.sendDeviceSetupDone (done: true) { result in
//            self.log("targetDevice.sendDeviceSetupDone: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                  targetDevice.isSetupDone = true
//                onComplete()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func stopCommissionerListening() {
//        self.commissionerDevice!.transceiver!.sendStopListening { result in
//            self.log("commissionerDevice.sendStopListening: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                self.stopTargetDeviceListening {
//                    self.stepComplete(.FinishJoinSelectedNetwork)
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func stopTargetDeviceListening(onComplete: @escaping () -> ()) {
//        self.targetDevice.transceiver!.sendStopListening { result in
//            self.log("targetDevice.sendStopListening: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//            if (result == .NONE) {
//                onComplete()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//


//
//    //MARK: StopTargetDeviceListening
//    private func stepStopTargetDeviceListening() {
//        self.stopTargetDeviceListening {
//            self.stepComplete(.StopTargetDeviceListening)
//        }
//    }

//
//    //MARK: GetNewDeviceName
//    private func stepGetNewDeviceName() {
//        self.delegate.meshSetupDidRequestToEnterDeviceName()
//    }
//
//    func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
//        guard currentCommand == .GetNewDeviceName else {
//            onComplete(.IllegalOperation)
//            return
//        }
//
//        guard self.validateDeviceName(name) else {
//            onComplete(.NameTooShort)
//            return
//        }
//
//        ParticleCloud.sharedInstance().getDevice(self.targetDevice.deviceId!) { device, error in
//            if (self.canceled) {
//                return
//            }
//
//            if (error == nil) {
//                device!.rename(name) { error in
//                    if error == nil {
//                        self.targetDevice.name = name
//                        onComplete(nil)
//                        self.stepComplete(.GetNewDeviceName)
//                    } else {
//                        onComplete(.UnableToRenameDevice)
//                        return
//                    }
//                }
//            } else {
//                onComplete(.UnableToRenameDevice)
//                return
//            }
//        }
//    }
//
//
//
//    //MARK:OfferToAddOneMoreDevice
//    private func stepOfferToAddOneMoreDevice() {
//        //disconnect current device
//        if (self.targetDevice.transceiver != nil) {
//            self.log("Dropping connection to target device")
//            let connection = self.targetDevice.transceiver!.connection
//            self.targetDevice.transceiver = nil
//            self.bluetoothManager.dropConnection(with: connection)
//        }
//
//        self.delegate.meshSetupDidRequestToAddOneMoreDevice()
//    }
//
//
//    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError? {
//        guard currentCommand == .OfferToAddOneMoreDevice else {
//            return .IllegalOperation
//        }
//
//        if (addOneMoreDevice) {
//            self.currentStep = 0
//            self.currentFlow = preflow
//            self.runCurrentStep()
//        } else {
//            self.finishSetup()
//        }
//
//        return nil
//    }
//
//
//    //MARK: GetNewNetworkNameAndPassword
//    private func stepGetNewNetworkNameAndPassword() {
//        self.delegate.meshSetupDidRequestToEnterNewNetworkNameAndPassword()
//    }
//
//
//    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
//        guard currentCommand == .GetNewNetworkNameAndPassword else {
//            return .IllegalOperation
//        }
//
//        guard self.validateNetworkName(name) else {
//            return .NameTooShort
//        }
//
//        if let networks =  self.apiNetworks {
//            for network in networks {
//                if (network.name.lowercased() == name.lowercased()) {
//                    return .NameInUse
//                }
//            }
//        }
//
//
//        self.log("set network name: \(name)")
//        self.newNetworkName = name
//
//        if (self.newNetworkName != nil && self.newNetworkPassword != nil) {
//            self.stepComplete(.GetNewNetworkNameAndPassword)
//        }
//
//        return nil
//    }
//
//
//    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
//        guard currentCommand == .GetNewNetworkNameAndPassword else {
//            return .IllegalOperation
//        }
//
//        guard self.validateNetworkPassword(password) else {
//            return .PasswordTooShort
//        }
//
//        self.log("set network password: \(password)")
//        self.newNetworkPassword = password
//
//        if (self.newNetworkName != nil && self.newNetworkPassword != nil) {
//            self.stepComplete(.GetNewNetworkNameAndPassword)
//        }
//
//        return nil
//    }
//
//
//
//    //MARK: CreateNetwork
//    private func stepCreateNetwork() {
//        self.delegate.meshSetupDidEnterState(state: .CreateNetworkStarted)
//
//        if (self.newNetworkId == nil) {
//            self.createNetworkInAPI()
//        } else {
//            self.createNetworkInMesh()
//        }
//    }
//
//    private func createNetworkInAPI() {
//
//        var networkType = ParticleNetworkType.microWifi
//        if let interface = self.targetDevice.activeInternetInterface, interface == .ppp {
//            networkType = ParticleNetworkType.microCellular
//        }
//
//        ParticleCloud.sharedInstance().createNetwork(self.newNetworkName!,
//                gatewayDeviceID: self.targetDevice.deviceId!,
//                gatewayDeviceICCID: networkType == .microCellular ? self.targetDevice.deviceICCID : nil,
//                networkType: networkType) {
//            network, error in
//            if (self.canceled) {
//                return
//            }
//
//            self.log("createNetwork: \(network as Optional), error: \(error as Optional)")
//            guard error == nil else {
//                self.fail(withReason: .UnableToCreateNetwork, nsError: error)
//                return
//            }
//
//            if let network = network {
//                self.newNetworkId = network.id
//
//                self.delegate.meshSetupDidEnterState(state: .CreateNetworkStep1Done)
//                self.createNetworkInMesh()
//            }
//        }
//    }
//
//    private func createNetworkInMesh() {
//        self.targetDevice.transceiver!.sendCreateNetwork(name: self.newNetworkName!, password: self.newNetworkPassword!, networkId: self.newNetworkId!) {
//            result, networkInfo in
//
//            self.log("targetDevice.sendCreateNetwork: \(result.description()), networkInfo: \(networkInfo as Optional)")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.log("Setting current target device as commissioner device part 1")
//                self.selectedNetworkMeshInfo = networkInfo!
//                self.selectedNetworkPassword = self.newNetworkPassword
//
//                self.delegate.meshSetupDidCreateNetwork(network: MeshSetupNetworkCellInfo(name: networkInfo!.name, extPanID: networkInfo!.extPanID, userOwned: true, deviceCount: 1))
//
//                self.setTargetDeviceSetupDone {
//                    self.setTargetDeviceAsCommissioner()
//                    self.delegate.meshSetupDidEnterState(state: .CreateNetworkCompleted)
//                    self.stepComplete(.CreateNetwork)
//                }
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func setTargetDeviceAsCommissioner() {
//        self.log("Setting current target device as commissioner device part 2")
//        self.commissionerDevice = self.targetDevice
//        self.targetDevice = MeshDevice()
//    }
//
//
//    func prepareForTargetDeviceReboot(onComplete: @escaping () -> ()) {
//        self.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { result in
//            self.log("targetDevice.sendSetStartupMode: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                onComplete()
//            } else if (result == .NOT_SUPPORTED) {
//                onComplete()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    func sendDeviceReset() {
//        self.targetDevice.transceiver!.sendSystemReset() { result  in
//            self.log("targetDevice.sendSystemReset: \(result.description())")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                //if all is fine, connection will be dropped and the setup will return few steps in dropped connection handler
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//}