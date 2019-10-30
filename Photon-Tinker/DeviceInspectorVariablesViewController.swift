//
//  DeviceInspectorFunctionsViewController.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 05/16/19.
//  Copyright (c) 2019 Particle. All rights reserved.
//



class DeviceInspectorVariablesViewController: DeviceInspectorChildViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DeviceVariableTableViewCellDelegate {

    @IBOutlet weak var noVariablesMessage: UILabel!
    @IBOutlet var noVariablesMessageView: UIView!
    
    var variableValues: [String: String?] = [:]
    var variableNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
        self.noVariablesMessageView.removeFromSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func resetUserAppData() {
        super.resetUserAppData()

        self.variableNames = []
        self.variableValues = [:]
    }

    override func update() {
        super.update()

        self.variableNames = self.device.variables.keys.sorted()
        self.loadAllVariables()
        self.tableView.reloadData()
        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

        self.setupTableViewHeader()
    }

    private func setupTableViewHeader() {
        if (self.device.connected) {
            self.noVariablesMessage.text = TinkerStrings.Variables.NoExposedVariables
        } else {
            self.noVariablesMessage.text = TinkerStrings.Variables.DeviceIsOffline
        }

        self.tableView.tableHeaderView = nil
        self.noVariablesMessageView.removeFromSuperview()
        self.tableView.tableHeaderView = (self.variableNames.count > 0) ? nil : self.noVariablesMessageView
        self.adjustTableViewHeaderViewConstraints()
    }

    override func showTutorial() {
        if (variableNames.count > 0) {
            if ParticleUtils.shouldDisplayTutorialForViewController(self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    // 1
                    let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) //

                    var tutorial = YCTutorialBox(headline: TinkerStrings.Variables.Tutorial.Tutorial1.Title, withHelpText: TinkerStrings.Variables.Tutorial.Tutorial1.Message)
                    tutorial?.showAndFocus(firstCell)

                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
            }
        }
    }


    func loadAllVariables() {
        if (!self.device.connected) {
            return
        }

        self.variableValues.removeAll()
        if (self.shouldLoadVariables()) {
            for name in self.variableNames {
                self.loadVariable(name)
            }
        }
    }

    func shouldLoadVariables() -> Bool {
        if (self.device.connected && self.variableNames.count <= 20) {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.variableNames.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: DeviceVariableTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "variableCell") as! DeviceVariableTableViewCell

        let name = variableNames[indexPath.row]

        var type: String!
        switch self.device.variables[name] {
            case "int32":
                type = "Integer"
            case "double":
                type = "Float"
            default:
                type = "String"
        }

        if self.variableValues.keys.contains(name) {
            let value = self.variableValues[name]!

            cell.setup(variableName: name, variableType: type, variableValue: value)
            if (value == nil) {
                cell.startUpdating()
            } else {
                cell.stopUpdating()
            }
        } else {
            cell.setup(variableName: name, variableType: type, variableValue: nil)
            cell.stopUpdating()
        }

        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func loadVariable(_ name: String) {
        if (!self.device.connected) {
            DispatchQueue.main.async {
                RMessage.showNotification(withTitle: TinkerStrings.Variables.Error.DeviceOffline.Title, subtitle: TinkerStrings.Variables.Error.DeviceOffline.Message, type: .error, customTypeName: nil, duration: -1, callback: nil)
            }
            return
        }

        if self.variableValues.keys.contains(name) && self.variableValues[name] == nil {
            //already loading
            return
        }

        variableValues.updateValue(nil, forKey: name)

        self.device.getVariable(name) { [weak self, name] variableValue, error in
            if let self = self {
                if let error = error {
                    self.variableValues[name] = nil
                } else {
                    if let resultValue = variableValue as? String {
                        self.variableValues[name] = resultValue
                    } else if let resultValue = variableValue as? NSNumber {
                        self.variableValues[name] = resultValue.stringValue
                    } else {
                        self.variableValues[name] = nil
                    }
        }

                DispatchQueue.main.async {
                    self.updateCellForVariable(name)
                }
            }
        }
    }

    func updateCellForVariable(_ name: String) {
        for cell in tableView.visibleCells as! [DeviceVariableTableViewCell] {
            if (cell.variableName == name) {
                if self.variableValues.keys.contains(name) {
                    if let value = self.variableValues[name] {
                        cell.setVariableValue(value: value)
                    } else {
                        cell.setVariableError()
                    }
                } else {
                    cell.setVariableError()
                }
                return
            }
        }
    }


    //MARK - Value cell delegate
    func tappedOnVariableName(_ sender: DeviceVariableTableViewCell, name: String) {
        self.loadVariable(name)
    }

    func tappedOnVariableValue(_ sender: DeviceVariableTableViewCell, name: String, value: String) {
        let alert = UIAlertController(title: name, message: value, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.CopyToClipboard, style: .default) { [weak self] action in
            UIPasteboard.general.string = value
            RMessage.showNotification(withTitle: TinkerStrings.Variables.Prompt.VariableCopied.Title, subtitle: TinkerStrings.Variables.Prompt.VariableCopied.Message, type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_VariableCopied")
        })

        alert.addAction(UIAlertAction(title: TinkerStrings.Action.Close, style: .cancel) { action in

        })

        self.present(alert, animated: true)
    }

}
