//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshSetupStyle {

    //fonts
    static var BasicFont: String = "Gotham-Book"
    static var SemiBoldFont: String = "Gotham-Medium"
    static var BoldFont: String = "Gotham-Book"

    //text sizes
    static var DetailSize = 12
    static var SmallSize = 14
    static var RegularSize = 16
    static var LargeSize = 18

    //colors
    static var TextColor = UIColor.colorWithHexString("333333")
    static var PlaceHolderColor = UIColor.colorWithHexString("A9A9A9")

    static var ButtonColor = UIColor.colorWithHexString("02ADEF")
    static var ButtonTitleColor = UIColor.colorWithHexString("FFFFFF")
}

class MeshLabel : UILabel {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }

    func localize() {
        self.text = NSLocalizedString(self.text ?? "", tableName: "MeshSetupStrings", comment: "")

        if (self.numberOfLines == 0) {
            self.sizeToFit()
        }
    }
}

class MeshSetupButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        //self.clipsToBounds = true
        self.layer.cornerRadius = 3.0

        self.backgroundColor = MeshSetupStyle.ButtonColor

        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 1.0


        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.yellow, for: .selected)
        self.setTitleColor(.yellow, for: .highlighted)

        self.tintColor = .purple
    }
}

extension UIColor {
    static func colorWithHexString(_ hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(UIColor.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!

        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    private static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}