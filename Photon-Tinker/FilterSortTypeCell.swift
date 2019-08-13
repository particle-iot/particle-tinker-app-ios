//
// Created by Raimundas Sakalauskas on 2019-08-05.
// Copyright (c) 2019 spark. All rights reserved.
//


import UIKit
import QuartzCore

internal class FilterSortTypeCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var cellHighlight: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryType = .checkmark
        tintColor = ParticleStyle.ButtonColor.withAlphaComponent(0)

        selectedBackgroundView = UIView()
        selectedBackgroundView!.backgroundColor = .clear

        cellHighlight = UIView()
        cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        cellHighlight.translatesAutoresizingMaskIntoConstraints = false
        cellHighlight.alpha = 0
        insertSubview(cellHighlight, belowSubview: titleLabel)
        NSLayoutConstraint.activate(
                [
                    cellHighlight.leftAnchor.constraint(equalTo: self.leftAnchor),
                    cellHighlight.rightAnchor.constraint(equalTo: self.rightAnchor),
                    cellHighlight.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    cellHighlight.topAnchor.constraint(equalTo: self.topAnchor)
                ]
        )
    }

    func setup(option: DeviceListSortingOptions) {
        titleLabel.text = option.description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.tintColor = ParticleStyle.ButtonColor.withAlphaComponent(selected ? 1 : 0)
            }
        } else {
            self.tintColor = ParticleStyle.ButtonColor.withAlphaComponent(selected ? 1 : 0)
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.cellHighlight.alpha = highlighted ? 1 : 0
            }
        } else {
            self.cellHighlight.alpha = highlighted ? 1 : 0
        }
    }


}
