//
//  HelpTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 7/7/16.
//  Copyright © 2016 Particle. All rights reserved.
//


class HelpTableViewCell: UITableViewCell {

    @IBOutlet weak var bkgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bkgView.layer.cornerRadius = 4
        self.bkgView.layer.masksToBounds = true
        
    }
    
    @IBOutlet weak var helpItemLabel: UILabel!
    
}
