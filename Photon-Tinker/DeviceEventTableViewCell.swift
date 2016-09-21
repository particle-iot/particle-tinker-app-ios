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
                let utcDateStr = e.time.description.replacingOccurrences(of: "+0000", with: "")
                
                // create dateFormatter with UTC time format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                let date = dateFormatter.date(from: utcDateStr)
                
                // change to a readable time format and change to local time zone
                dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
                let timeStamp = dateFormatter.string(from: date!)
                
                self.eventTimeValueLabel.text = timeStamp
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 6
        self.bkgView.layer.masksToBounds = true
    
    }
    
    
    @IBAction func copyEventButtonTapped(_ sender: UIButton) {
        if let e = event {
            UIPasteboard.general.string = e.description
            TSMessage.showNotification(withTitle: "Copied", subtitle: "Event payload was copied to the clipboard", type: .success)
            SEGAnalytics.shared().track("Device Inspector: event copied")
        }
    }
}
