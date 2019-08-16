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

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear

        self.cellHighlight = UIView()
        self.cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor
        self.cellHighlight.translatesAutoresizingMaskIntoConstraints = false
        self.cellHighlight.alpha = 0
        self.contentView.insertSubview(self.cellHighlight, at: 0)
        self.contentView.layer.masksToBounds = false
        NSLayoutConstraint.activate(
                [
                    self.cellHighlight.leftAnchor.constraint(equalTo: self.leftAnchor),
                    self.cellHighlight.rightAnchor.constraint(equalTo: self.rightAnchor),
                    self.cellHighlight.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    self.cellHighlight.topAnchor.constraint(equalTo: self.topAnchor)
                ]
        )
    }

    func setup(option: DeviceListSortingOptions) {
        self.titleLabel.text = option.description
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
        self.cellHighlight.backgroundColor = ParticleStyle.CellHighlightColor

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.cellHighlight.alpha = highlighted ? 1 : 0
            }
        } else {
            self.cellHighlight.alpha = highlighted ? 1 : 0
        }
    }


}
