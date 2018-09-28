//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshDeviceCell : UITableViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: MeshLabel!
    @IBOutlet weak var cellSubtitleLabel: MeshLabel!
    @IBOutlet weak var cellAccessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }


}
