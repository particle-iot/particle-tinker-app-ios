//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelSimDataLimitViewController : MeshSetupControlPanelRootViewController {

    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!
    @IBOutlet weak var noteLabel: MeshLabel!
    
    private var currentLimitIdx: Int!
    private var selectedIdx: Int!
    private var disableValuesSmallerThanCurrent: Bool!

    private var dataLimitCallback: ((Int) -> ())!

    override class var nibName: String {
        return String(describing: self)
    }

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Cellular.DataLimit.Title
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

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.DetailsTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        textLabel.text = MeshSetupStrings.ControlPanel.Cellular.DataLimit.Text
        noteLabel.text = MeshSetupStrings.ControlPanel.Cellular.DataLimit.Note
        continueButton.setTitle(MeshSetupStrings.ControlPanel.Cellular.DataLimit.ContinueButton, for: .normal)

        continueButton.isEnabled = false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell

        if (!self.disableValuesSmallerThanCurrent) {
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        } else if (indexPath.row > self.currentLimitIdx) {
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        }


        if let selected = selectedIdx, indexPath.row == selected {
            cell.accessoryType = .checkmark
            cell.tintColor = MeshSetupStyle.ButtonColor
        } else if (indexPath.row == currentLimitIdx) {
            cell.accessoryType = .checkmark
            cell.tintColor = MeshSetupStyle.SecondaryTextColor
        } else {
            cell.accessoryType = .none
        }

        let limit = cellValues[indexPath.row]
        cell.cellTitleLabel.text =  MeshSetupStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{0}}", with: String(limit))

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
        cell.tintColor = MeshSetupStyle.ButtonColor

        self.continueButton.isEnabled = selectedIdx! != currentLimitIdx
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellValues.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()

        dataLimitCallback(cellValues[self.selectedIdx])
    }


}
