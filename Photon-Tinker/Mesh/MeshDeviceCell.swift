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

        let cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        self.selectedBackgroundView = cellHighlight

        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }




}
