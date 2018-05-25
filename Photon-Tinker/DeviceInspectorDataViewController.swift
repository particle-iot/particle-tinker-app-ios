//
//  DeviceInspectorDataViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 particle. All rights reserved.
//



class DeviceInspectorDataViewController: DeviceInspectorChildViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DeviceVariableTableViewCellDelegate {
    
    @IBOutlet weak var deviceDataTableView: UITableView!
    
    // Standard colors
    
    
    var variablesList : [String]?
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white//ParticleUtils.particleAlmostWhiteColor
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGray// particleDarkGrayColor
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        DispatchQueue.global().async {
            // do some task
            // auto read all variables
            var index : IndexPath
            
            
            IQKeyboardManager.shared().shouldHidePreviousNext = true
            
            
            for i in 0..<self.tableView(self.deviceDataTableView, numberOfRowsInSection: 1) {
                index = IndexPath(row: i, section: 1)
                let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.cellForRow(at: index) as? DeviceVariableTableViewCell
                
                if let c = cell {
                    if c.device == nil {
                        return
                    }
                } else {
                    cell?.readButtonTapped(self)
                }
            }
            
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().shouldHidePreviousNext = false
    }
    
    
    
    override func showTutorial() {
    
        
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                if !self.view.isHidden {
                    // viewController is visible
                    
         
                    let firstCell = self.deviceDataTableView.cellForRow(at: IndexPath(row: 0, section: 0)) //
                    
                    // 1
                    let tutorial = YCTutorialBox(headline: "Device Data", withHelpText: "Tap the function cell to access the arguments box. Type in function arguments (comma separated if more than one) and tap send or the function name to call it.\n\nSimply tap a variable name to read its current value. Tap any long variable value to show a popup with the full string value in case it has been truncated.")
                    
                    tutorial?.showAndFocus(firstCell)
                    
                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
                }
                
            }
        }
    }

    
    
    func refreshVariableList() {
        
        self.variablesList = [String]()
        for (key, value) in (self.device?.variables)! {
            var varType : String = ""
            switch value {
            case "int32" :
                varType = "Integer"
            case "double" :
                varType = "Float"
            default:
                varType = "String"
            }
            self.variablesList?.append(String("\(key),\(varType)"))
        }
        
    
        self.deviceDataTableView.reloadData()
    }
    
    
    internal var readVarsOnce : Bool = false
    func readAllVariablesOnce() {
        
        if (!readVarsOnce) {
            
            for j in 0...deviceDataTableView.numberOfRows(inSection: 1)
            {
                if let cell = deviceDataTableView.cellForRow(at: IndexPath(row: j, section: 1)) {
                    
                    let varCell = cell as! DeviceVariableTableViewCell
                    if varCell.variableName != "" {
                        varCell.readButtonTapped(self)
                    }
                }
                
            }
            readVarsOnce = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        switch section {
        case 0 : title = "Particle.function()"
        default : title = "Particle.variable()"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return max(self.device!.functions.count,1)
        default : return max(self.device!.variables.count,1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        var masterCell : UITableViewCell?
        var masterCell : UITableViewCell?
        //        var selected : Bool = false
        //
        //        if let selectedIndexPaths = tableView.indexPathsForSelectedRows where selectedIndexPaths.contains(indexPath) {
        //            selected = true
        //        }
        //
        
        
        switch (indexPath as NSIndexPath).section {
        case 0 : // Functions
            let cell : DeviceFunctionTableViewCell? = self.deviceDataTableView.dequeueReusableCell(withIdentifier: "functionCell") as? DeviceFunctionTableViewCell
            if (self.device!.functions.count == 0) {
                // something else
                cell!.functionName = ""
                cell!.device = nil
            } else {
                cell!.functionName = self.device?.functions[(indexPath as NSIndexPath).row]
                cell!.device = self.device
            }
            
            //            cell?.centerFunctionNameLayoutConstraint.constant = selected ? 0 : -20
            
            masterCell = cell
            
        default :
            let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.dequeueReusableCell(withIdentifier: "variableCell") as? DeviceVariableTableViewCell
            
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
            //            cell?.variableNameCenterLayoutConstraint.constant = selected ? 0 : -20
            
            masterCell = cell;
            
        }
        
        masterCell?.selectionStyle = .none
        
        
        return masterCell!
    }
    
    
    func tappedOnVariable(_ sender: DeviceVariableTableViewCell, name: String, value: String) {
        ZAlertView.messageFont = UIFont(name: "FiraMono-Regular", size: 13.0)
        ZAlertView.messageTextAlignment = NSTextAlignment.left
        
        let dialog = ZAlertView(title: name, message: value, alertType: .multipleChoice)
        
        dialog.addButton("Copy to clipboard", font: ParticleUtils.particleBoldFont, color: ParticleUtils.particleCyanColor, titleColor: ParticleUtils.particleAlmostWhiteColor) { (dialog : ZAlertView) in
            
            UIPasteboard.general.string = value
            TSMessage.showNotification(withTitle: "Copied", subtitle: "Variable value was copied to the clipboard", type: .success)
            SEGAnalytics.shared().track("Device Inspector: variable copied")
        }
        
        
        dialog.addButton("Close", font: ParticleUtils.particleRegularFont, color: ParticleUtils.particleGrayColor, titleColor: UIColor.white) { (dialog : ZAlertView) in
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
        let cell : DeviceDataTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceDataTableViewCell
        
        if cell.device == nil || (indexPath as NSIndexPath).section > 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            
            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceFunctionTableViewCell
            let halfRotation = CGFloat(M_PI)
            
            UIView.animate(withDuration: 0.3, animations: {
                cellAnim.argumentsButton.transform = CGAffineTransform(rotationAngle: halfRotation)
                }, completion: { (done: Bool) in
                cellAnim.argumentsTextField.becomeFirstResponder()
            })
            
            updateTableView()
            
        }
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell : DeviceDataTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceDataTableViewCell
        
        if cell.device != nil && (indexPath as NSIndexPath).section == 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)
            
            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceFunctionTableViewCell
            
            UIView.animate(withDuration: 0.3, animations: {
                // animating `transform` allows us to change 2D geometry of the object
                // like `scale`, `rotation` or `translate`
                cellAnim.argumentsButton.transform = CGAffineTransform.identity//CGAffineTransformMakeRotation(halfRotation)
            })
            
            
        }
        updateTableView()
        view.endEditing(true)
    }
    
    fileprivate func updateTableView() {
        self.deviceDataTableView.beginUpdates()
        self.deviceDataTableView.endUpdates()
    }
    
    
    //    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView!
    //    {
    //        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
    //        headerView.backgroundColor = UIColor.clearColor()
    
    
    //
    //        UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    //        tempLabel.backgroundColor=[UIColor clearColor];
    //        tempLabel.shadowColor = [UIColor blackColor];
    //        tempLabel.shadowOffset = CGSizeMake(0,2);
    //        tempLabel.textColor = [UIColor redColor]; //here you can change the text color of header.
    //        tempLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSizeForHeaders];
    //        tempLabel.font = [UIFont boldSystemFontOfSize:fontSizeForHeaders];
    //        tempLabel.text=@"Header Text";
    //
    //        [tempView addSubview:tempLabel];
    //
    //        [tempLabel release];
    //        return tempView;
    
    //
    //        return headerView
    //    }
    //
    
    
       
}
