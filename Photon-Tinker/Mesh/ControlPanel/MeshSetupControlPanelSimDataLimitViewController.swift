//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class MeshSetupControlPanelSimDataLimitViewController : MeshSetupControlPanelRootViewController {

    @IBOutlet weak var textLabel: ParticleLabel!
    @IBOutlet weak var continueButton: ParticleButton!
    @IBOutlet weak var noteLabel: ParticleLabel!
    
    private var currentLimitIdx: Int!
    private var selectedIdx: Int!
    private var disableValuesSmallerThanCurrent: Bool!

    private var dataLimitCallback: ((Int) -> ())!

    override class var nibName: String {
        return String(describing: self)
    }

    override var customTitle: String {
        return MeshStrings.ControlPanel.Cellular.DataLimit.Title
    }

    internal var cellValues = [
        1, 2, 3, 5,
        10, 20, 50,
        100, 200, 500
    ]

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(currentLimit: Int, disableValuesSmallerThanCurrent: Bool, callback: @escaping (Int) -> ()) {
        self.currentLimitIdx = cellValues.firstIndex(of: currentLimit)!
        self.selectedIdx = self.currentLimitIdx
        self.disableValuesSmallerThanCurrent = disableValuesSmallerThanCurrent
        self.dataLimitCallback = callback

    }

    override func setStyle() {
        self.tableView.tableFooterView = UIView()

        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        noteLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.DetailsTextColor)
        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        textLabel.text = MeshStrings.ControlPanel.Cellular.DataLimit.Text
        noteLabel.text = MeshStrings.ControlPanel.Cellular.DataLimit.Note
        continueButton.setTitle(MeshStrings.ControlPanel.Cellular.DataLimit.ContinueButton, for: .normal)

        continueButton.isEnabled = false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell

        if (!self.disableValuesSmallerThanCurrent) {
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        } else if (indexPath.row > self.currentLimitIdx) {
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        } else {
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.SecondaryTextColor)
        }


        if let selected = selectedIdx, indexPath.row == selected {
            cell.accessoryType = .checkmark
            cell.tintColor = ParticleStyle.ButtonColor
        } else if (indexPath.row == currentLimitIdx) {
            cell.accessoryType = .checkmark
            cell.tintColor = ParticleStyle.DisclosureIndicatorColor
        } else {
            cell.accessoryType = .none
        }

        let limit = cellValues[indexPath.row]
        cell.cellTitleLabel.text =  MeshStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{dataLimit}}", with: String(limit))

        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (!self.disableValuesSmallerThanCurrent) {
            return true
        } else if (indexPath.row > self.currentLimitIdx) {
            return true
        } else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let prevSelectedIdx: Int! = self.selectedIdx;
        selectedIdx = indexPath.row

        tableView.reloadRows(at: [
            IndexPath(row: prevSelectedIdx, section: 0),
        ], with: .automatic)


        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        cell.tintColor = ParticleStyle.ButtonColor

        self.continueButton.isEnabled = selectedIdx! != currentLimitIdx
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellValues.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()

        dataLimitCallback(cellValues[self.selectedIdx])
    }


}
