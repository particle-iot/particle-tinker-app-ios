//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class Gen3SetupControlPanelRootViewController : Gen3SetupViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate {

    class var nibName: String {
        return "Gen3SetupControlPanelActionList"
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

    internal var callback: ((Gen3SetupControlPanelCellType) -> ())!

    internal var device: ParticleDevice!
    internal var cells: [[Gen3SetupControlPanelCellType]]!

    internal weak var context: Gen3SetupContext!


    override var customTitle: String {
        return Gen3SetupStrings.ControlPanel.Root.Title
    }

    override func setStyle() {
        //do nothing
    }

    override func setContent() {
        //do nothing
    }

    func setup(device: ParticleDevice, context: Gen3SetupContext!, didSelectAction: @escaping (Gen3SetupControlPanelCellType) -> ()) {
        self.callback = didSelectAction

        self.context = context
        self.device = device

        self.prepareContent()
    }


    internal func prepareContent() {
        cells = [[.name, .notes]]

        switch device.type {
            case .xenon, .xSeries:
                cells.append([.ethernet, .mesh])
            case .boron, .bSeries, .b5SoM:
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

        Gen3SetupControlPanelCellType.prepareTableView(tableView)
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
            return UITableView.automaticDimension
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
