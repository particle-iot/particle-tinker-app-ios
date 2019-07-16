//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelRootViewController : MeshSetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    class var nibName: String {
        return "MeshSetupControlPanelActionList"
    }

    override var allowBack: Bool {
        get {
            return false
        }
        set {
            super.allowBack = newValue
        }
    }

    @IBOutlet weak var tableView: UITableView!

    internal var callback: ((MeshSetupControlPanelCellType) -> ())!

    internal var device: ParticleDevice!
    internal var cells: [[MeshSetupControlPanelCellType]]!

    internal weak var context: MeshSetupContext!


    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Root.Title
    }

    override func setStyle() {
        //do nothing
    }

    override func setContent() {
        //do nothing
    }

    func setup(device: ParticleDevice, context: MeshSetupContext!, didSelectAction: @escaping (MeshSetupControlPanelCellType) -> ()) {
        self.callback = didSelectAction

        self.context = context
        self.device = device

        self.context.targetDevice.name = self.device.getName()
        self.context.targetDevice.notes = self.device.notes
        self.context.targetDevice.networkRole = self.device.networkRole

        self.prepareContent()
    }


    internal func prepareContent() {
        cells = [[.name, .notes]]

        switch device.type {
            case .xenon, .xSeries:
                cells.append([.ethernet, .mesh])
            case .boron, .bSeries:
                cells.append([.cellular, .ethernet, .mesh])
            case .argon, .aSeries:
                cells.append([.wifi, .ethernet, .mesh])
            default:
                break
        }

        cells.append([.documentation])
        cells.append([.unclaim])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        if (viewsToFade == nil) {
            viewsToFade = [self.tableView]
        } else {
            viewsToFade?.append(self.tableView)
        }

        MeshSetupControlPanelCellType.prepareTableView(tableView)
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == self.numberOfSections(in: tableView) - 1) {
            return 60
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.section][indexPath.row]
        return cellType.getConfiguredCell(tableView, context: self.context)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellType = cells[indexPath.section][indexPath.row]

        return cellType.getCellEnabled(context: self.context)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let command = cells[indexPath.section][indexPath.row]

        let showSpinner = (command != .notes && command != .name)
        self.fadeContent(animated: true, showSpinner: showSpinner)

        self.callback(cells[indexPath.section][indexPath.row])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
