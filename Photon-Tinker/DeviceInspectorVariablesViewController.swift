//
//  DeviceInspectorDataViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 Particle. All rights reserved.
//



class DeviceInspectorDataViewController: DeviceInspectorChildViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DeviceVariableTableViewCellDelegate {

    enum DeviceInspectorDataViewMode {
        case variables
        case functions
    }

    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl!
    var mode: DeviceInspectorDataViewMode!

    func setup(mode: DeviceInspectorDataViewMode, device: ParticleDevice) {
        self.mode = mode
        self.device = device
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addRefreshControl()
    }

    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
        self.readAllVariables()
    }

    override func viewDidAppear(_ animated: Bool) {
        var index: IndexPath

        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide;
    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .default
    }

    override func update() {
        super.update()

        self.tableView.reloadData()
        self.readAllVariables()
        self.refreshControl.endRefreshing()
    }

    override func showTutorial() {
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                if !self.view.isHidden {
                    let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) //

                    // 1
                    let tutorial = YCTutorialBox(headline: "Device Data", withHelpText: "Tap the function cell to access the arguments box. Type in function arguments (comma separated if more than one) and tap send or the function name to call it.\n\nSimply tap a variable name to read its current value. Tap any long variable value to show a popup with the full string value in case it has been truncated.")
                    tutorial?.showAndFocus(firstCell)
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
            }
        }
    }

    
    
    func reloadData() {
        if (mode == .variables) {
            self.variablesList = [String]()
            for (key, value) in (self.device?.variables)! {
                var varType: String = ""
                switch value {
                    case "int32":
                        varType = "Integer"
                    case "double":
                        varType = "Float"
                    default:
                        varType = "String"
                }
                self.variablesList?.append(String("\(key),\(varType)"))
            }
        }

        self.tableView.reloadData()
    }
    

    func readAllVariables() {
        if (!readVarsOnce) {
            for j in 0...tableView.numberOfRows(inSection: 1)
            {
                if let cell = tableView.cellForRow(at: IndexPath(row: j, section: 1)) {
                    let varCell = cell as! DeviceVariableTableViewCell
                    if varCell.variableName != "" {
                        varCell.readButtonTapped(self)
                    }
                }
                
            }
            readVarsOnce = true
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white

        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch mode! {
            case .functions: return "Particle.function()" 
            case .variables: return "Particle.variable()"
            default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode! {
            case .functions: return max(self.device!.functions.count,1)
            case .variables: return max(self.device!.variables.count,1)
            default: return 0
        }
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode! {
            case .functions: // Functions
                let cell: DeviceFunctionTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "functionCell") as? DeviceFunctionTableViewCell
                if (self.device!.functions.count == 0) {
                    // something else
                    cell!.functionName = ""
                    cell!.device = nil
                } else {
                    cell!.functionName = self.device?.functions[(indexPath as NSIndexPath).row]
                    cell!.device = self.device
                }

                cell!.selectionStyle = .none

                return cell!
            case .variables:
                let cell: DeviceVariableTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "variableCell") as? DeviceVariableTableViewCell

                if (self.device!.variables.count == 0) {
                    cell!.variableName = ""
                } else {
                    if let vl = self.variablesList {
                        let varArr =  vl[(indexPath as NSIndexPath).row].characters.split{$0 == ","}.map(String.init)
                        //
                        cell!.variableType = varArr[1]
                        cell!.variableName = varArr[0]
                        cell!.device = self.device
                        cell!.delegate = self
                    }
                }
                cell!.selectionStyle = .none

                return cell!
        }

        fatalError("not implemented!")
    }
    
    
    func tappedOnVariable(_ sender: DeviceVariableTableViewCell, name: String, value: String) {
        ZAlertView.messageFont = UIFont(name: "FiraMono-Regular", size: 13.0)
        ZAlertView.messageTextAlignment = NSTextAlignment.left
        
        let dialog = ZAlertView(title: name, message: value, alertType: .multipleChoice)
        
        dialog.addButton("Copy to clipboard", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog: ZAlertView) in
            
            UIPasteboard.general.string = value
            RMessage.showNotification(withTitle: "Copied", subtitle: "Variable value was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_VariableCopied")
        }
        
        
        dialog.addButton("Close", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.white) { (dialog: ZAlertView) in
            dialog.dismiss()
//            ZAlertView.messageTextAlignment = NSTextAlignment.Center
        }
        
        dialog.show()
}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows , selectedIndexPaths.contains(indexPath) {
            return 96.0 // Expanded height
        }
        
        return 48.0 // Normal height
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: DeviceDataTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceDataTableViewCell

        if cell.device != nil && mode == .functions {
            let cellAnim: DeviceFunctionTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceFunctionTableViewCell
            let halfRotation = CGFloat(M_PI)
            
            UIView.animate(withDuration: 0.3, animations: {
                cellAnim.argumentsButton.transform = CGAffineTransform(rotationAngle: halfRotation)
                }, completion: { (done: Bool) in
                cellAnim.argumentsTextField.becomeFirstResponder()
            })
            
            updateTableView()
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: DeviceDataTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceDataTableViewCell

        if cell.device != nil && mode == .functions {
            let cellAnim: DeviceFunctionTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceFunctionTableViewCell
            
            UIView.animate(withDuration: 0.3, animations: {
                cellAnim.argumentsButton.transform = CGAffineTransform.identity
            })
        }
        updateTableView()
        view.endEditing(true)
    }

    fileprivate func updateTableView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @objc func refreshData(sender: UIRefreshControl) {
        self.delegate?.childViewDidRequestDataRefresh(self)
    }
}
