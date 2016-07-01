//
//  DeviceEventTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 spark. All rights reserved.
//



class DeviceEventTableViewCell: DeviceDataTableViewCell {

    @IBOutlet weak var bkgView: UIView!
    
    @IBOutlet weak var eventTimeValueLabel: UILabel!
    @IBOutlet weak var eventDataValueLabel: UILabel!
    @IBOutlet weak var eventNameValueLabel: UILabel!
    
    
    var event : SparkEvent? {
        didSet {
            if let e = event {
                
                
                self.eventNameValueLabel.text = e.event
                self.eventDataValueLabel.text = e.data
                
                // convert weird UTC stamp to human readable local time
                let utcDateStr = e.time.description.stringByReplacingOccurrencesOfString("+0000", withString: "")
                
                // create dateFormatter with UTC time format
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "UTC")
                let date = dateFormatter.dateFromString(utcDateStr)
                
                // change to a readable time format and change to local time zone
                dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                let timeStamp = dateFormatter.stringFromDate(date!)
                
                self.eventTimeValueLabel.text = timeStamp
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 4
        self.bkgView.layer.masksToBounds = true
    
    }
    
    
    @IBAction func copyEventButtonTapped(sender: UIButton) {
        if let e = event {
            UIPasteboard.generalPasteboard().string = e.description
            TSMessage.showNotificationWithTitle("Copied", subtitle: "Event payload was copied to the clipboard", type: .Success)
        }
    }
}
