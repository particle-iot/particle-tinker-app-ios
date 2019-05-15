//
//  DeviceEventTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright © 2016 particle. All rights reserved.
//



class DeviceEventTableViewCell: DeviceDataTableViewCell {

    @IBOutlet weak var bkgView: UIView!
    
    @IBOutlet weak var eventTimeValueLabel: UILabel!
    @IBOutlet weak var eventDataValueLabel: UILabel!
    @IBOutlet weak var eventNameValueLabel: UILabel!
    
    
    var event: ParticleEvent!

    func setup(_ event: ParticleEvent) {
        self.eventNameValueLabel.text = event.event
        self.eventDataValueLabel.text = event.data

        // convert weird UTC stamp to human readable local time
        let utcDateStr = event.time.description.replacingOccurrences(of: "+0000", with: "")

        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: utcDateStr)!

        self.eventTimeValueLabel.text = "\(DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)), \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 6
        self.bkgView.layer.masksToBounds = true
    
    }
    
    
    @IBAction func copyEventButtonTapped(_ sender: UIButton) {
        if let e = event {
            UIPasteboard.general.string = e.description
            RMessage.showNotification(withTitle: "Copied", subtitle: "Event payload was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
            SEGAnalytics.shared().track("DeviceInspector_EventCopied")
        }
    }
}
