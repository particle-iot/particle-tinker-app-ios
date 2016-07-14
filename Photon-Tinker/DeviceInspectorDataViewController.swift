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
        view.tintColor = ParticleUtils.particleAlmostWhiteColor
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
    
    override func viewWillAppear(animated: Bool) {
        // move to refresh function
        
        self.refreshVariableList()
        
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
        print ("select "+indexPath.description)
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
        print ("deselect "+indexPath.description)
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
