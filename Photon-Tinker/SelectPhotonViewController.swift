//
//  SelectPhotonViewController.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class SelectPhotonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        var backgroundImage = UIImageView(image: UIImage(named: "imgBackgroundCore"))
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        
        // Do any additional setup after loading the view.
    }

    var items: [String] = ["trashy_fox", "agent_orange", "test_core2"]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var photonSelectionTableView: UITableView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.photonSelectionTableView.dequeueReusableCellWithIdentifier("photon") as! UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    @IBAction func refreshButtonTapped(sender: UIButton) {
        self.photonSelectionTableView.reloadData()
        //...
    }
    
    
    @IBAction func logoutButtonTapped(sender: UIButton) {

    }

    
}
