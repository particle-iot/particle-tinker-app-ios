//
// Created by Raimundas Sakalauskas on 2019-08-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class FiltersButton: UIButton {
    var highlightBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.adjustImages()
        self.adjustBackground()

    }

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue

            self.adjustImages()
        }
    }
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue

            self.adjustBackground()
        }
    }

    private func adjustBackground() {
        let backgroundImage = self.getBackgroundImage()
        self.setBackgroundImage(backgroundImage.image(withColor: ParticleStyle.ButtonColor), for: .selected)
        self.setBackgroundImage(nil, for: .normal)
    }

    private func adjustImages() {
        let image = self.image(for: .normal)

        if self.isSelected {
            self.setImage(image?.image(withColor: UIColor.white.withAlphaComponent(1.00)), for: .normal)
            self.setImage(image?.image(withColor: UIColor.white.withAlphaComponent(0.25)), for: .highlighted)
        } else {
            self.setImage(image?.image(withColor: UIColor.black.withAlphaComponent(1.00)), for: .normal)
            self.setImage(image?.image(withColor: UIColor.black.withAlphaComponent(0.25)), for: .highlighted)
        }
    }

    func getBackgroundImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: self.frame.width, height: self.frame.height))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)

            let rectangle = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            let path = UIBezierPath(roundedRect: rectangle, cornerRadius: 3).cgPath
            ctx.cgContext.addPath(path)
            ctx.cgContext.drawPath(using: .fill)
        }
    }
}
