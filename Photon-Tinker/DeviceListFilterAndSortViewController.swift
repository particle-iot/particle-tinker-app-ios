//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceListFilterAndSortViewController: UIViewController, SortByViewDelegate, DeviceTypeViewDelegate, DeviceStatusViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var showButton: ParticleButton!
    @IBOutlet weak var sortByView: SortByView!
    @IBOutlet weak var deviceStatusView: DeviceStatusView!
    @IBOutlet weak var deviceTypeView: DeviceTypeView!

    private weak var dataSource: DeviceListDataSource!
    private var viewDataSource: DeviceListDataSource!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            if self.responds(to: Selector("overrideUserInterfaceStyle")) {
                self.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }

        self.modalPresentationStyle = .fullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortByView.delegate = self
        self.deviceStatusView.delegate = self
        self.deviceTypeView.delegate = self

        self.showButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
        self.updateShowButtonTitle()
    }



    func sortOptionDidChange(sortByView: SortByView, option: DeviceListSortingOptions) {
        self.viewDataSource.setSortOption(option)
    }

    func deviceTypeOptionDidChange(deviceTypeView: DeviceTypeView, options: [DeviceTypeOptions]) {
        self.viewDataSource.setDeviceTypeOptions(options)
    }

    func deviceStatusOptionDidChange(deviceStatusView: DeviceStatusView, options: [DeviceOnlineStatusOptions]) {
        self.viewDataSource.setOnlineStatusOptions(options)
    }

    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true) { }
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        self.sortByView.reset()
        self.deviceStatusView.reset()
        self.deviceTypeView.reset()
    }
    
    @IBAction func showClicked(_ sender: Any) {
        self.dataSource.apply(with: self.viewDataSource)
        self.dismiss(animated: true) { }
    }

    private func updateShowButtonTitle() {
        if (self.viewDataSource.viewDevices.count == 1) {
            self.showButton.setTitle(TinkerStrings.Filters.Button.ShowDevicesSingular.replacingOccurrences(of: "{{count}}", with: String(self.viewDataSource.viewDevices.count)), for: .normal)
        } else {
            self.showButton.setTitle(TinkerStrings.Filters.Button.ShowDevicesPlural.replacingOccurrences(of: "{{count}}", with: String(self.viewDataSource.viewDevices.count)), for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.sortByView.setup(selectedSortOption: self.viewDataSource.sortOption)
        self.deviceStatusView.setup(selectedOptions: self.viewDataSource.onlineStatusOptions)
        self.deviceTypeView.setup(selectedOptions: self.viewDataSource.typeOptions)
    }

    func setup(dataSource: DeviceListDataSource) {
        self.dataSource = dataSource
        self.viewDataSource = (self.dataSource.copy(with: nil) as! DeviceListDataSource)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(filtersChanged(_:)), name: NSNotification.Name.DeviceListFilteringChanged, object: self.viewDataSource)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.viewDataSource = nil
        NotificationCenter.default.removeObserver(self)
    }

    @objc func filtersChanged(_ sender: AnyObject) {
        self.updateShowButtonTitle()
    }
}
