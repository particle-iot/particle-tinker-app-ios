//
//  DeviceEventTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 6/30/16.
//  Copyright (c) 2019 Particle. All rights reserved.
//

protocol DeviceEventTableViewCellDelegate: class  {
    func tappedOnCopyButton(_ sender : DeviceEventTableViewCell, event : ParticleEvent)
    func tappedOnPayloadButton(_ sender : DeviceEventTableViewCell, event : ParticleEvent)
}

class DeviceEventTableViewCell: UITableViewCell {

    @IBOutlet weak var bkgView: UIView!
    
    @IBOutlet weak var eventTimeValueLabel: UILabel!
    @IBOutlet weak var eventDataValueLabel: UILabel!
    @IBOutlet weak var eventNameValueLabel: UILabel!

    weak var delegate : DeviceEventTableViewCellDelegate?
    
    var event: ParticleEvent!

    func setup(_ event: ParticleEvent) {
        self.event = event

        self.eventNameValueLabel.text = event.event
        self.eventDataValueLabel.text = event.data ?? ""
        self.eventTimeValueLabel.text = event.time.eventTimeFormattedString()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 6
        self.bkgView.layer.masksToBounds = true
    
    }

    @IBAction func payloadButtonTapped(_ sender: UIButton) {
        self.delegate?.tappedOnPayloadButton(self, event: self.event)
    }
    
    @IBAction func copyEventButtonTapped(_ sender: UIButton) {
        self.delegate?.tappedOnCopyButton(self, event: self.event)
    }
}
