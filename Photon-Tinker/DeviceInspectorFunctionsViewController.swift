//
//  DeviceInspectorFunctionsViewController.swift
//  Particle
//
//  Created by Raimundas Sakalauskas on 05/16/19.
//  Copyright © 2019 Particle. All rights reserved.
//



class DeviceInspectorFunctionsViewController: DeviceInspectorChildViewController, UITableViewDelegate, UITableViewDataSource, DeviceFunctionTableViewCellDelegate {

    @IBOutlet weak var noFunctionsMessage: UILabel!
    @IBOutlet var noFunctionsMessageView: UIView!

    var functionValues: [String: String?] = [:]
    var functionArguments: [String: String] = [:]
    var functionNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
        self.noFunctionsMessageView.removeFromSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func resetUserAppData() {
        super.resetUserAppData()

        self.functionNames = []
        self.functionArguments = [:]
        self.functionValues = [:]
    }

    override func update() {
        super.update()

        self.functionNames = self.device.functions.sorted()
        self.tableView.reloadData()
        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

        self.setupTableViewHeader()
    }

    private func setupTableViewHeader() {
        if (self.device.connected) {
            self.noFunctionsMessage.text = "No exposed variables"
        } else {
            self.noFunctionsMessage.text = "Device is offline"
        }

        self.tableView.tableHeaderView = nil
        self.noFunctionsMessageView.removeFromSuperview()
        self.tableView.tableHeaderView = (self.functionNames.count > 0) ? nil : self.noFunctionsMessageView

        self.adjustTableViewHeaderViewConstraints()
    }

    let tutorials = [
        ("Device Functions", "Tap the function cell to access the arguments box. Type in function arguments (comma separated if more than one) and tap send or the function name to call it.")
    ]

    override func showTutorial() {
        if (functionNames.count > 0) {
            if ParticleUtils.shouldDisplayTutorialForViewController(self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) //

                    var tutorial = YCTutorialBox(headline: self.tutorials[0].0, withHelpText: self.tutorials[0].1)
                    tutorial?.showAndFocus(firstCell)

                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide;
    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .default
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows , selectedIndexPaths.contains(indexPath) {
            return 96.0 // Expanded height
        }

        return 48.0 // Normal height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.functionNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceFunctionTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "functionCell") as! DeviceFunctionTableViewCell

        let name = self.functionNames[indexPath.row]

        cell.setup(functionName: name)

        if let argument = self.functionArguments[name] {
            cell.argumentsTextField.text = argument
        }

        if self.functionValues.keys.contains(name) {
            let value = self.functionValues[name]!

            //if value is nil, we are currently running api call
            if let value = value {
                cell.setFunctionValue(value: value)
            } else {
                cell.startUpdating()
            }
        }

        cell.delegate = self
        cell.selectionStyle = .none
        cell.tag = indexPath.row

        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tappedOnFunctionName(_ sender: DeviceFunctionTableViewCell, name: String, argument: String) {
        self.callFunction(name, argument: argument)
    }
    
    func callFunction(_ name: String, argument: String) {
        if (!self.device.connected) {
            DispatchQueue.main.async {
                RMessage.showNotification(withTitle: "Device offline", subtitle: "Device is offline. To execute functions device must be online.", type: .error, customTypeName: nil, duration: -1, callback: nil)
            }
            return
        }

        if self.functionValues.keys.contains(name) && self.functionValues[name] == nil {
            //already loading
            return
        }

        functionValues.updateValue(nil, forKey: name)

        SEGAnalytics.shared().track("DeviceInspector_FunctionCalled")
        self.device?.callFunction(name, withArguments: [argument]) { [weak self, name] functionValue, error in
            if let self = self {
                if let error = error {
                    self.functionValues[name] = nil
                } else {
                    if let resultValue = functionValue {
                        self.functionValues[name] = resultValue.stringValue
                    } else {
                        self.functionValues[name] = nil
                    }
                }

                DispatchQueue.main.async {
                    self.updateCellForFunction(name)
                }
            }
        }
    }
    
    func updateCellForFunction(_ name: String) {
        for cell in tableView.visibleCells as! [DeviceFunctionTableViewCell] {
            if (cell.functionName == name) {
                if self.functionValues.keys.contains(name) {
                    if let value = self.functionValues[name] {
                        cell.setFunctionValue(value: value)
                    } else {
                        cell.setFunctionError()
                    }
                } else {
                    cell.setFunctionError()
                }
                return
            }
        }
    }

    

    func updateArgument(_ sender: DeviceFunctionTableViewCell, argument: String) {
        self.functionArguments[sender.functionName] = argument
    }

    func tappedOnExpandButton(_ sender: DeviceFunctionTableViewCell) {
        self.tableView.beginUpdates()
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at:indexPath) {
            if cell.isSelected {
                self.tableView.deselectRow(at: indexPath, animated: false)
            } else {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        self.tableView.endUpdates()
    }
}
