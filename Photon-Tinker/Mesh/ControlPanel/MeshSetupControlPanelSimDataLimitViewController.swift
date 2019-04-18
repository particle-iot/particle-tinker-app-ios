//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelSimDataLimitViewController : MeshSetupControlPanelRootViewController {

    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!

    private var currentLimitIdx: Int!
    private var selectedIdx: Int!

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

    func setup(currentLimit: Int, callback: @escaping (Int) -> ()) {
        self.currentLimitIdx = cellValues.firstIndex(of: currentLimit)!
        self.selectedIdx = self.currentLimitIdx
        self.dataLimitCallback = callback
    }

    override func setStyle() {
        self.tableView.tableFooterView = UIView()

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        textLabel.text = MeshSetupStrings.ControlPanel.Cellular.DataLimit.Text
        continueButton.setTitle(MeshSetupStrings.ControlPanel.Cellular.DataLimit.ContinueButton, for: .normal)

        continueButton.isEnabled = false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeshCell! = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell
        cell.cellTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)


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
        return true
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
