//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshCell : UITableViewCell {
    @IBOutlet weak var cellTitleLabel: MeshLabel!
    @IBOutlet weak var cellSubtitleLabel: MeshLabel!
    @IBOutlet weak var cellIconImageView: UIImageView?
    @IBOutlet weak var cellAccessoryImageView: UIImageView!
    @IBOutlet weak var cellSecondaryAccessoryImageView: UIImageView!
    @IBOutlet weak var cellDetailLabel: MeshLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }


}
