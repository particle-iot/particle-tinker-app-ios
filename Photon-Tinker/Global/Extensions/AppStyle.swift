//
// Created by Raimundas Sakalauskas on 2019-06-03.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class ParticleStyle {

    //fonts
    static var RegularFont: String = "AvenirNext-Regular"
    static var ItalicFont: String = "AvenirNext-Italic"
    static var BoldFont: String = "AvenirNext-DemiBold"

    //text sizes
    static var DetailSize = 12
    static var SmallSize = 14
    static var RegularSize = 16
    static var LargeSize = 18
    static var ExtraLargeSize = 22
    static var PriceSize = 48

    //colors
    static var PrimaryTextColor = UIColor.colorWithHexString("#333333")
    static var SecondaryTextColor = UIColor.colorWithHexString("#B1B1B1")
    static var DetailsTextColor = UIColor.colorWithHexString("#8A8A8F")
    static var RedTextColor = UIColor.colorWithHexString("#ED1C24")

    static var DisclosureIndicatorColor = UIColor.colorWithHexString("#B1B1B1")

    static var BillingTextColor = UIColor.colorWithHexString("#76777A")
    static var StrikeThroughColor = UIColor.colorWithHexString("#002F87")

    static var DisabledTextColor = UIColor.colorWithHexString("#A9A9A9")
    static var PlaceHolderTextColor = UIColor.colorWithHexString("#A9A9A9")

    static var InputTitleColor = UIColor.colorWithHexString("#777777")
    static var NoteBackgroundColor = UIColor.colorWithHexString("#F7F7F7")
    static var NoteBorderColor = UIColor.colorWithHexString("#C7C7C7")

    static var ProgressBarProgressColor = UIColor.colorWithHexString("#02ADEF")
    static var ProgressBarTrackColor = UIColor.colorWithHexString("#F5F5F5")

    static var EthernetToggleBackgroundColor = UIColor.colorWithHexString("#F5F5F5")
    static var ViewBackgroundColor = UIColor.colorWithHexString("#FFFFFF")


    static var AlternativeButtonColor = UIColor.colorWithHexString("#FFFFFF")
    static var AlternativeButtonBorderColor = UIColor.colorWithHexString("#02ADEF")
    static var AlternativeButtonTitleColor = UIColor.colorWithHexString("#02ADEF")

    static var ButtonColor = UIColor.colorWithHexString("#02ADEF")
    static var ButtonRedColor = UIColor.colorWithHexString("#ED1C24")
    static var ButtonTitleColor = UIColor.colorWithHexString("#FFFFFF")

    static var TableViewBackgroundColor = UIColor.colorWithHexString("#EFEFF4")
    static var CellSeparatorColor = UIColor.colorWithHexString("#BCBBC1")
    static var CellHighlightColor = UIColor.colorWithHexString("#F5F5F5")


    static var PairingActivityIndicatorColor = UIColor.colorWithHexString("#02ADEF")
    static var NetworkScanActivityIndicatorColor = UIColor.colorWithHexString("#333333")
    static var NetworkJoinActivityIndicatorColor = UIColor.colorWithHexString("#333333")
    static var ProgressActivityIndicatorColor = UIColor.colorWithHexString("#333333")

}

class ParticleButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = MeshSetupStyle.ButtonColor

        self.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 2, spread: 0)
    }

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title?.uppercased(), for: state)
    }

    func setStyle(font: String, size: Int) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))

        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .normal)
        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .selected)
        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .highlighted)
        self.setTitleColor(ParticleStyle.ButtonTitleColor.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = ParticleStyle.ButtonTitleColor
            self.imageView?.tintColor = ParticleStyle.ButtonTitleColor
        }
    }
}