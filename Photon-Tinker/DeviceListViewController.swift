//
//  DeviceListViewController.swift
//  Photon-Tinker
//
//  Copyright (c) 2019 particle. All rights reserved.
//

import UIKit
import QuartzCore


class DeviceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParticleSetupMainControllerDelegate, ParticleDeviceDelegate, Fadeable, SearchBarViewDelegate {

    @IBOutlet weak var setupNewDeviceButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noDevicesLabel: UILabel!
    @IBOutlet var noDevicesView: UIView!

    @IBOutlet weak var searchBar: SearchBarView!
    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl!
    var initialLoadComplete: Bool = false

    var isBusy: Bool = false
    var viewsToFade: [UIView]? = nil

    var popRecognizer: InteractivePopGestureRecognizerDelegateHelper?

    var dataSource: DeviceListDataSource!

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }



    @objc func appDidBecomeActive(_ sender : AnyObject) {
        if (!self.isBusy) {
            if ParticleCloud.sharedInstance().isAuthenticated {
                self.initialLoadComplete = false
            }
            self.fade(animated: true)
            self.loadDevices()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.dataSource = DeviceListDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewsToFade = [self.tableView, self.moreButton, self.setupNewDeviceButton, self.searchBar, self.filtersButton]

        self.tableView.tableFooterView = UIView()

        self.setupSearch()


        self.noDevicesView.removeFromSuperview()
        if ParticleCloud.sharedInstance().isAuthenticated {
            self.addRefreshControl()

            if (!self.isBusy) {
                self.fade(animated: false)
                self.loadDevices()
            }

            self.initialLoadComplete = false
        } else {
            self.initialLoadComplete = true
            self.reloadData()
        }
    }

    private func setupSearch() {
        searchBar.inputText.placeholder = TinkerStrings.DeviceList.SearchPlaceholder
        searchBar.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let controller = navigationController, popRecognizer == nil {
            popRecognizer = InteractivePopGestureRecognizerDelegateHelper(controller: controller, minViewControllers: 2)
            controller.interactivePopGestureRecognizer?.delegate = popRecognizer
        }

        self.reloadData()

        SEGAnalytics.shared().track("Tinker_DeviceListScreenActivity")
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(filtersChanged(_:)), name: NSNotification.Name.DeviceListFilteringChanged, object: self.dataSource)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }



    //MARK: Refresh control
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ParticleStyle.SecondaryTextColor
        refreshControl.addTarget(self, action:  #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    @objc func refreshData(sender: UIRefreshControl? = nil) {
        if (!self.isBusy) {
            self.fadeContent(animated: true, showSpinner: false)
            self.loadDevices()
        }
    }


    func loadDevices()
    {
        guard ParticleCloud.sharedInstance().isAuthenticated else {
            return
        }

        self.isBusy = true
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices started", withParameters: getVaList([]))

        ParticleCloud.sharedInstance().getDevices({ [weak self] devices, error in
            guard let self = self else { return }

            DispatchQueue.main.async { [weak self] () -> () in
                if let self = self {
                    self.initialLoadComplete = true
                    self.handleGetDevicesResponse(devices, error: error)
                    self.resume(animated: true)
                    self.tableView.refreshControl?.endRefreshing()
                    self.showTutorial()
                    self.isBusy = false
                }
            }
        })
    }

    func handleGetDevicesResponse(_ devices:[ParticleDevice]?, error:Error?)
    {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed", withParameters: getVaList([]))
        if let e = error
        {
            self.dataSource.setDevices([])

            if (e as NSError).code == 401 {
                self.logout()
            } else {
                ParticleLogger.logError(NSStringFromClass(type(of: self)), format: "Load devices error", withParameters: getVaList([]))
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.LoadingDevicesFailed.Title, subtitle: TinkerStrings.DeviceList.Error.LoadingDevicesFailed.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                }
            }
        }
        else
        {
            for device in devices! {
                device.delegate = self
            }

            self.dataSource.setDevices(devices!)

            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Load devices completed. Device count: %i", withParameters: getVaList([devices!.count]))
            DispatchQueue.main.async {
                ParticleLogger.logDebug(NSStringFromClass(type(of: self)), format: "Devices: %@", withParameters: getVaList([devices!]))
            }

            DispatchQueue.main.async {
                // if no devices offer user to setup a new one
                if (devices!.count == 0) {
                    self.setupNewDeviceButtonTapped(self.setupNewDeviceButton)
                }
            }
        }
    }




    //MARK: Tutorials
    func showTutorial() {
       if ParticleUtils.shouldDisplayTutorialForViewController(self) {
           DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                if (ParticleCloud.sharedInstance().isAuthenticated && self.dataSource.viewDevices.count > 0) {
                    // 1
                    let tutorial2 = YCTutorialBox(headline: TinkerStrings.DeviceList.Tutorial.Tutorial2.Title, withHelpText: TinkerStrings.DeviceList.Tutorial.Tutorial2.Message)

                    // 0
                    let tutorial = YCTutorialBox(headline: TinkerStrings.DeviceList.Tutorial.Tutorial1.Title, withHelpText: TinkerStrings.DeviceList.Tutorial.Tutorial1.Message) {
                        tutorial2?.showAndFocus(self.setupNewDeviceButton)
                    }
                    let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) //
                    tutorial?.showAndFocus(firstCell)
                } else {
                    var tutorial = YCTutorialBox(headline: TinkerStrings.DeviceList.Tutorial.Tutorial2.Title, withHelpText: TinkerStrings.DeviceList.Tutorial.Tutorial2.Message)
                    tutorial?.showAndFocus(self.setupNewDeviceButton)
                }

                ParticleUtils.setTutorialWasDisplayedForViewController(self)
            }
        }
    }



    //MARK: Search bar delegate
    func searchBarTextDidChange(searchBar: SearchBarView, text: String?) {
        self.dataSource.setSearchTerm(text)
    }

    func searchBarDidBeginEditing(searchBar: SearchBarView) {

    }

    func searchBarDidEndEditing(searchBar: SearchBarView) {

    }


    //MARK: Particle device delegate
    func particleDevice(_ device: ParticleDevice, didReceive event: ParticleDeviceSystemEvent) {
        DispatchQueue.main.async {
            self.reloadData()
        }

        NotificationCenter.default.post(name: Notification.Name.ParticleDeviceSystemEvent, object: nil, userInfo: [
            "device": device,
            "event": event
        ])
    }

    @objc func filtersChanged(_ sender: AnyObject) {
        self.reloadData()
    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.dataSource.reloadData()
            self.filtersButton.isSelected = self.dataSource.isFiltering()
            self.setupTableViewHeader()
            self.tableView.reloadData()
        }
    }

    private func setupTableViewHeader() {
        self.tableView.tableHeaderView = nil
        self.noDevicesView.removeFromSuperview()

        if !self.initialLoadComplete {
            return
        }

        self.tableView.tableHeaderView =  (self.dataSource.viewDevices.count  > 0) ? nil : self.noDevicesView

        if self.tableView.tableHeaderView != nil {
            if  self.dataSource.devices.count == 0 {
                self.noDevicesLabel.text = TinkerStrings.DeviceList.NoDevices
            } else if self.dataSource.isSearching() {
                self.noDevicesLabel.text = TinkerStrings.DeviceList.NoDevicesMatchingSearch.replacingOccurrences(of: "{{searchTerm}}", with: self.dataSource.searchTerm!)
            } else if self.dataSource.isFiltering() {
                self.noDevicesLabel.text = TinkerStrings.DeviceList.NoDevicesForCurrentFilter
            }
        }

        self.adjustTableViewHeaderViewConstraints()
    }

    func adjustTableViewHeaderViewConstraints() {
        if (self.tableView.tableHeaderView == nil) {
            return
        }

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.heightAnchor, constant: -8),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.widthAnchor),
                self.tableView.tableHeaderView!.centerXAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.centerXAnchor),
                self.tableView.tableHeaderView!.centerYAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.heightAnchor, constant: -8),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.widthAnchor),
                self.tableView.tableHeaderView!.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor),
                self.tableView.tableHeaderView!.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor)
            ])
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }


    //MARK: Device setup setup
    func invokeElectronSetup() {
        SEGAnalytics.shared().track("Tinker_ElectronSetupInvoked")

        let esVC : ElectronSetupViewController = self.storyboard!.instantiateViewController(withIdentifier: "electronSetup") as! ElectronSetupViewController
        self.present(esVC, animated: true, completion: nil)
    }

    func invokeMeshDeviceSetup() {
        SEGAnalytics.shared().track("Tinker_3rdGenSetupInvoked")

        let setupFlow = MeshSetupFlowUIManager.loadedViewController()
        setupFlow.setCallback(flowCallback)
        self.present(setupFlow, animated: true)
    }

    func flowCallback(result: MeshSetupFlowResult, data: [AnyObject]? = nil) {
        if result == .success {
            self.refreshData()

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                if (self.dataSource.devices.count == 1) {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulFirstDevice.Title, subtitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulFirstDevice.Title, type: .success, customTypeName: nil, callback: nil)
                } else {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Prompt.SetupSuccessful.Title, subtitle: TinkerStrings.DeviceList.Prompt.SetupSuccessful.Title, type: .success, customTypeName: nil, callback: nil)
                }
            }
        } else if (result == .switchToControlPanel) {
            guard let vc = data?.first as? MeshSetupControlPanelUIManager else {
                fatalError("vc was not available for switchToControlPanel result")
            }

            self.performSegue(withIdentifier: "deviceInspector", sender: vc)
        }

        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "3rd setup ended: %@", withParameters: getVaList([result.description]))
        SEGAnalytics.shared().track("Tinker_3rdGenSetupEnded", properties: ["result": result.description])
    }

    func invokePhotonDeviceSetup()
    {
        let c = ParticleSetupCustomization.sharedInstance()

        c?.pageBackgroundColor = UIColor(rgb: 0xF0F0F0)
        c?.pageBackgroundImage = nil

        c?.normalTextColor = ParticleUtils.particleDarkGrayColor
        c?.linkTextColor = ParticleUtils.particleDarkGrayColor

        c?.modeButtonName = TinkerStrings.DeviceList.PhotonLib.ModeButtonName

        c?.elementTextColor = UIColor.white
        c?.elementBackgroundColor = ParticleUtils.particleCyanColor
        c?.brandImage = UIImage(named: "ImgParticleLogoHorizontal")
        c?.brandImageBackgroundColor = .clear
        c?.brandImageBackgroundImage = UIImage(named: "ImgAppHeader")

        c?.tintSetupImages = false
        c?.instructionalVideoFilename = TinkerStrings.DeviceList.PhotonLib.InstructionsVideo.iOS
        c?.allowPasswordManager = true
        c?.lightStatusAndNavBar = true
        c?.disableLogOutOption = true

        if let vc = ParticleSetupMainController(setupOnly: !ParticleCloud.sharedInstance().isAuthenticated)
        {
            SEGAnalytics.shared().track("Tinker_PhotonSetupInvoked")
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!) {
        if result == .success
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup ended successfully", withParameters: getVaList([]))
            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"success"])

            if (self.dataSource.devices.count == 1) {
                RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulFirstDevice.Title, subtitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulFirstDevice.Title, type: .success, customTypeName: nil, callback: nil)
            } else {
                RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Prompt.SetupSuccessful.Title, subtitle: TinkerStrings.DeviceList.Prompt.SetupSuccessful.Title, type: .success, customTypeName: nil, callback: nil)
            }
        }
        else if result == .successNotClaimed
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup ended successfully, not claimed (Wi-Fi credentials flow).", withParameters: getVaList([]))
            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"successNotClaimed"])

            RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulWifiOnly.Title, subtitle: TinkerStrings.DeviceList.Prompt.SetupSuccessfulWifiOnly.Message, type: .success, customTypeName: nil, callback: nil)
        }
        else
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup cancelled or failed.", withParameters: getVaList([]))
            SEGAnalytics.shared().track("Tinker_PhotonSetupEnded", properties: ["result":"failed or canceled"])

            RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.SetupNotCompleted.Title, subtitle: TinkerStrings.DeviceList.Error.SetupNotCompleted.Message, type: .warning, customTypeName: nil, callback: nil)
        }

        self.refreshData()
    }


    //MARK: Tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.viewDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceListCell = self.tableView.dequeueReusableCell(withIdentifier: "deviceCell") as! DeviceListCell
        if (indexPath.row < self.dataSource.viewDevices.count) {
            cell.setup(device: self.dataSource.viewDevices[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // user swiped left
        if editingStyle == .delete
        {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Showing unclaim confirmation", withParameters: getVaList([]))

            let alert = UIAlertController(title: MeshStrings.ControlPanel.Unclaim.TextTitle.meshLocalized(),
                    message: MeshStrings.ControlPanel.Unclaim.Text.meshLocalized().replaceMeshSetupStrings(deviceName: self.dataSource.viewDevices[(indexPath as NSIndexPath).row].getName()),
                    preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: MeshStrings.ControlPanel.Action.Cancel.meshLocalized(), style: .cancel))

            alert.addAction(UIAlertAction(title: MeshStrings.ControlPanel.Unclaim.UnclaimButton.meshLocalized(), style: .default) { [weak self] action in
                guard let self = self else {
                    return
                }

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Unclaiming device: %@", withParameters: getVaList([self.dataSource.viewDevices[(indexPath as NSIndexPath).row]]))

                self.dataSource.viewDevices[(indexPath as NSIndexPath).row].unclaim() { (error: Error?) -> Void in
                    if let err = error
                    {
                        RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.UnclaimingFailed.Title, subtitle: TinkerStrings.DeviceList.Error.UnclaimingFailed.Message.replacingOccurrences(of: "{{error}}", with: err.localizedDescription), type: .error, customTypeName: nil, duration: -1, callback: nil)
                        self.reloadData()
                    }
                }

                self.tableView.isUserInteractionEnabled = false


                let deviceToRemove = self.dataSource.viewDevices[(indexPath as NSIndexPath).row]
                var newDevices = self.dataSource.devices
                newDevices.removeAll { device in
                    device == deviceToRemove
                }

                //remove notification handler so that setting new devices doesn't trigger tableview reload prematurly
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DeviceListFilteringChanged, object: nil)
                self.dataSource.setDevices(newDevices)
                NotificationCenter.default.addObserver(self, selector: #selector(self.filtersChanged(_:)), name: NSNotification.Name.DeviceListFilteringChanged, object: nil)

                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                let delayTime = DispatchTime.now() + .milliseconds(250)

                ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device unclaim complete. Device count: %i, Devices: %@", withParameters: getVaList([self.dataSource.viewDevices.count, self.dataSource.viewDevices]))

                // update table view display to show dark/light cells with delay so that delete animation can complete nicely
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.tableView.isUserInteractionEnabled = true
                    self.reloadData()
                }
            })
            self.present(alert, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return TinkerStrings.DeviceList.Button.Unclaim
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isBusy == false else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Selected indexPath: %i", withParameters: getVaList([indexPath.row]))

        RMessage.dismissActiveNotification()
        tableView.deselectRow(at: indexPath, animated: true)

        self.isBusy = true
        self.fade(animated: true)

        let selectedDevice = self.dataSource.viewDevices[indexPath.row]
        selectedDevice.refresh { [weak self] error in
            if let self = self {
                if let error = error {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.GettingInformationFromCloudFailed.Title, subtitle: TinkerStrings.DeviceList.Error.GettingInformationFromCloudFailed.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                } else {
                    self.performSegue(withIdentifier: "deviceInspector", sender: selectedDevice)
                }

                self.resume(animated: true)
                self.isBusy = false
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceInspector" {
            if let vc = segue.destination as? DeviceInspectorViewController {
                if let device = sender as? ParticleDevice {
                    vc.setup(device: device)
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Segue into device inspector - device: %@", withParameters: getVaList(["\(device)"]))
                    SEGAnalytics.shared().track("Tinker_SegueToDeviceInspector", properties: ["device": device.type.description])
                } else if let cp = sender as? MeshSetupControlPanelUIManager {
                    vc.setup(device: cp.device, controlPanelViewController: cp)
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Segue into device inspector - device: %@, controlPanel: %@", withParameters: getVaList(["\(cp.device)", "\(cp)"]))
                    SEGAnalytics.shared().track("Tinker_SegueToDeviceInspector", properties: ["device": cp.device.type.description])
                }


            }
        } else if segue.identifier == "filters" {
            if let vc = segue.destination as? DeviceListFilterAndSortViewController {
                vc.setup(dataSource: self.dataSource)
                SEGAnalytics.shared().track("Tinker_SegueToFiltersView")

            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }


    //MARK: Handle actions
    private func logout() {
        ParticleCloud.sharedInstance().logout()

        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }

    @IBAction func setupNewDeviceButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: TinkerStrings.DeviceList.Prompt.SetupNewDevice.Title, message: nil, preferredStyle: .actionSheet)

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: TinkerStrings.Action.Setup3rdGen, style: .default) { action in
                if (ParticleCloud.sharedInstance().isAuthenticated) {
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Mesh setup started", withParameters: getVaList([]))
                    self.invokeMeshDeviceSetup()
                } else {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.AuthRequiredToSetup3rdGen.Title, subtitle: TinkerStrings.DeviceList.Error.AuthRequiredToSetup3rdGen.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                }
            })
        }


        alert.addAction(UIAlertAction(title: TinkerStrings.Action.SetupPhoton, style: .default) { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Photon setup started", withParameters: getVaList([]))
            self.invokePhotonDeviceSetup()
        })

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: TinkerStrings.Action.SetupElectron, style: .default) { action in
                if (ParticleCloud.sharedInstance().isAuthenticated) {
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Electron setup started", withParameters: getVaList([]))
                    self.invokeElectronSetup()
                } else {
                    RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.AuthRequiredToSetupElectron.Title, subtitle: TinkerStrings.DeviceList.Error.AuthRequiredToSetupElectron.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
                }
            })
        }


        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }



    @IBAction func moreButtonTapped(_ sender: UIButton) {
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "More tapped", withParameters: getVaList([]))

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if (ParticleCloud.sharedInstance().isAuthenticated) {
            alert.addAction(UIAlertAction(title: TinkerStrings.Action.LogOut, style: .default, handler: { action in
                let alert = UIAlertController(title: TinkerStrings.DeviceList.Prompt.LogOutConfirmation.Title, message: TinkerStrings.DeviceList.Prompt.LogOutConfirmation.Message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel))
                alert.addAction(UIAlertAction(title: TinkerStrings.Action.LogOut, style: .default) { action in
                    ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Logout confirmed", withParameters: getVaList([]))
                    self.logout()
                })
                self.present(alert, animated: true)
            }))
        } else {
            alert.addAction(UIAlertAction(title: TinkerStrings.Action.LogIn, style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
        }

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.ShareApplicationLogs, style: .default, handler: { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device logs selected", withParameters: getVaList([]))

            if let zipURL = LogList.getZip() {
                let avc = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
                self.present(avc, animated: true)
            } else {
                RMessage.showNotification(withTitle: TinkerStrings.DeviceList.Error.ExportingLogsFailed.Title, subtitle: TinkerStrings.DeviceList.Error.ExportingLogsFailed.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
            }
        }))

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel, handler: { action in
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Cancel tapped", withParameters: getVaList([]))
        }))

        self.present(alert, animated: true)
    }


    //MARK: Keyboard display
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - self.view.safeAreaInsets.bottom, right: 0)
            } else {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            }

            UIView.animate(withDuration: 0.25) { () -> Void in
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc  func keyboardWillHide(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }

            UIView.animate(withDuration: 0.25) { () -> Void in
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}
