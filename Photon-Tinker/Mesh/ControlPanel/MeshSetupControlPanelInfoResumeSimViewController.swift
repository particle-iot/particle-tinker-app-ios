//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelInfoResumeSimViewController : MeshSetupControlPanelInfoDeactivateSimViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    internal var requestShowDataLimit: (() -> ())!

    override var customTitle: String {
        return MeshStrings.ControlPanel.Cellular.ResumeSim.Title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none;

        let header = UIView(frame: CGRect(x: 0, y: 0, width: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 1))
        header.backgroundColor = ParticleStyle.NoteBorderColor.withAlphaComponent(0.5)
        tableView.tableHeaderView = header

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 1))
        footer.backgroundColor = ParticleStyle.NoteBorderColor.withAlphaComponent(0.5)
        tableView.tableFooterView = footer


        MeshSetupControlPanelCellType.prepareTableView(tableView)
    }

    func setup(context: MeshSetupContext, didFinish: @escaping () -> (), requestShowDataLimit: @escaping () -> ()) {
        super.setup(context: context, didFinish: didFinish)
        self.requestShowDataLimit = requestShowDataLimit
    }

    override func setContent() {
        titleLabel.text = MeshStrings.ControlPanel.Cellular.ResumeSim.TextTitle
        textLabel.text = MeshStrings.ControlPanel.Cellular.ResumeSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)

        continueButton.setTitle(MeshStrings.ControlPanel.Cellular.ResumeSim.ContinueButton, for: .normal)
        noteLabel.text = MeshStrings.ControlPanel.Cellular.ResumeSim.Note

        continueButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()

        if let setDataLimit = self.context.targetDevice.setSimDataLimit {
            self.continueButton.isEnabled = setDataLimit > self.context.targetDevice.sim!.dataLimit!
        } else {
            self.continueButton.isEnabled = false
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = MeshSetupControlPanelCellType.actionChangeDataLimit
        let cell = cellType.getConfiguredCell(tableView, context: self.context)

        if let dataLimit = self.context.targetDevice.setSimDataLimit {
            cell.cellDetailLabel.text = MeshStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{0}}", with: String(dataLimit))
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.fade()
        self.requestShowDataLimit()
    }

}
