//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceListFilterAndSortViewController: UIViewController, SortByViewDelegate, DeviceTypeViewDelegate, DeviceStatusViewDelegate {
    
    @IBOutlet weak var whiteBackground: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var showButton: ParticleButton!
    @IBOutlet weak var sortByView: SortByView!
    @IBOutlet weak var deviceStatusView: DeviceStatusView!
    @IBOutlet weak var deviceTypeView: DeviceTypeView!

    private weak var dataSource: DeviceListDataSource!

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
        self.dataSource.setSortOption(option)
    }

    func deviceTypeOptionDidChange(deviceTypeView: DeviceTypeView, options: [DeviceTypeOptions]) {
        self.dataSource.setDeviceTypeOptions(options)
    }

    func deviceStatusOptionDidChange(deviceStatusView: DeviceStatusView, options: [DeviceOnlineStatusOptions]) {
        self.dataSource.setOnlineStatusOptions(options)
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
        self.dismiss(animated: true) { }
    }

    private func updateShowButtonTitle() {
        if (self.dataSource.viewDevices.count == 1) {
            self.showButton.setTitle("Show {{0}} device".replacingOccurrences(of: "{{0}}", with: String(self.dataSource.viewDevices.count)), for: .normal)
        } else {
            self.showButton.setTitle("Show {{0}} devices".replacingOccurrences(of: "{{0}}", with: String(self.dataSource.viewDevices.count)), for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.sortByView.setup(selectedSortOption: self.dataSource.sortOption)
        self.deviceStatusView.setup(selectedOptions: self.dataSource.onlineStatusOptions)
        self.deviceTypeView.setup(selectedOptions: self.dataSource.typeOptions)
    }

    func setup(dataSource: DeviceListDataSource) {
        self.dataSource = dataSource
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(filtersChanged(_:)), name: NSNotification.Name.DeviceListFilteringChanged, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func filtersChanged(_ sender: AnyObject) {
        self.updateShowButtonTitle()
    }
}
