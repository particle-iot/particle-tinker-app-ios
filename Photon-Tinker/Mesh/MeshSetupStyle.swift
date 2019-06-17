//
// Created by Raimundas Sakalauskas on 2019-06-17.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class MeshSetupNoteView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3
        self.backgroundColor = ParticleStyle.NoteBackgroundColor

        self.layer.borderColor = ParticleStyle.NoteBorderColor.cgColor
        self.layer.borderWidth = 1
    }
}

class MeshCheckBoxButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: 15)
        self.setBackgroundImage(UIImage(named: "MeshCheckBox"), for: .normal)
        self.setBackgroundImage(UIImage(named: "MeshCheckBoxSelected"), for: .selected)
        self.setBackgroundImage(UIImage(named: "MeshCheckBoxSelected"), for: .highlighted)

        self.tintColor = .clear
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (bounds.height-20)/2, width: 20, height: 20)
    }
}
