//
//  DeviceInspectorDataViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 spark. All rights reserved.
//



class DeviceInspectorDataViewController: DeviceInspectorChildViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var deviceDataTableView: UITableView!
    
    // Standard colors
    
    
    var variablesList : [String]?
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()//ParticleUtils.particleAlmostWhiteColor
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGrayColor()// sparkDarkGrayColor
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            // auto read all variables
            var index : NSIndexPath
            
            
            IQKeyboardManager.sharedManager().shouldHidePreviousNext = true
            
            
            for i in 0..<self.tableView(self.deviceDataTableView, numberOfRowsInSection: 1) {
                index = NSIndexPath(forRow: i, inSection: 1)
                let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.cellForRowAtIndexPath(index) as? DeviceVariableTableViewCell
                
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
    
    
    
    override func viewWillDisappear(animated: Bool) {
        IQKeyboardManager.sharedManager().shouldHidePreviousNext = false
    }
    
    
    
    override func showTutorial() {
    
        
        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                if !self.view.hidden {
                    // viewController is visible
                    
         
                    let firstCell = self.deviceDataTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) //
                    
                    // 1
                    let tutorial = YCTutorialBox(headline: "Device Data", withHelpText: "Tap the function cell to access the arguments box. Type in function arguments (comma separated if more than one) and tap send or the function name to call it.\n\nSimply tap a variable name to read its current value.")
                    
                    tutorial.showAndFocusView(firstCell)
                    
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
            case "float" :
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
            
            for j in 0...deviceDataTableView.numberOfRowsInSection(1)
            {
                if let cell = deviceDataTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: 1)) {
                    
                    let varCell = cell as! DeviceVariableTableViewCell
                    if varCell.variableName != "" {
                        varCell.readButtonTapped(self)
                    }
                }
                
            }
            readVarsOnce = true
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        switch section {
        case 0 : title = "Particle.function()"
        default : title = "Particle.variable()"
        }
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return max(self.device!.functions.count,1)
        default : return max(self.device!.variables.count,1)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //        var masterCell : UITableViewCell?
        var masterCell : UITableViewCell?
        //        var selected : Bool = false
        //
        //        if let selectedIndexPaths = tableView.indexPathsForSelectedRows where selectedIndexPaths.contains(indexPath) {
        //            selected = true
        //        }
        //
        
        
        switch indexPath.section {
        case 0 : // Functions
            let cell : DeviceFunctionTableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("functionCell") as? DeviceFunctionTableViewCell
            if (self.device!.functions.count == 0) {
                // something else
                cell!.functionName = ""
                cell!.device = nil
            } else {
                cell!.functionName = self.device?.functions[indexPath.row]
                cell!.device = self.device
            }
            
            //            cell?.centerFunctionNameLayoutConstraint.constant = selected ? 0 : -20
            
            masterCell = cell
            
        default :
            let cell : DeviceVariableTableViewCell? = self.deviceDataTableView.dequeueReusableCellWithIdentifier("variableCell") as? DeviceVariableTableViewCell
            
            if (self.device!.variables.count == 0) {
                cell!.variableName = ""
            } else {
                let varArr =  self.variablesList![indexPath.row].characters.split{$0 == ","}.map(String.init)
                //
                cell!.variableType = varArr[1]
                cell!.variableName = varArr[0]
                cell!.device = self.device
            }
            //            cell?.variableNameCenterLayoutConstraint.constant = selected ? 0 : -20
            
            masterCell = cell;
            
        }
        
        masterCell?.selectionStyle = .None
        
        
        return masterCell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows where selectedIndexPaths.contains(indexPath) {
            return 96.0 // Expanded height
        }
        
        return 48.0 // Normal height
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : DeviceDataTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceDataTableViewCell
        
        if cell.device == nil || indexPath.section > 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            
            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceFunctionTableViewCell
            let halfRotation = CGFloat(M_PI)
            
            UIView.animateWithDuration(0.3, animations: {
                cellAnim.argumentsButton.transform = CGAffineTransformMakeRotation(halfRotation)
                }, completion: { (done: Bool) in
                cellAnim.argumentsTextField.becomeFirstResponder()
            })
            
            updateTableView()
            
        }
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : DeviceDataTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceDataTableViewCell
        
        if cell.device != nil && indexPath.section == 0 { // prevent expansion of non existent cells (no var/no func) || (just functions)
            
            let cellAnim : DeviceFunctionTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! DeviceFunctionTableViewCell
            
            UIView.animateWithDuration(0.3, animations: {
                // animating `transform` allows us to change 2D geometry of the object
                // like `scale`, `rotation` or `translate`
                cellAnim.argumentsButton.transform = CGAffineTransformIdentity//CGAffineTransformMakeRotation(halfRotation)
            })
            
            
        }
        updateTableView()
        view.endEditing(true)
    }
    
    private func updateTableView() {
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
