//
// Created by Raimundas Sakalauskas on 2019-04-24.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

extension UIColor {

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
                red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
                green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
                blue: CGFloat(rgb & 0xFF) / 255.0,
                alpha: alpha
        )
    }

    convenience init(string hexString: String) {
        assert(hexString.characters.count > 7, "Invalid hexString")

        let hexInt = Int(hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1)), radix: 16)
        guard let hex = hexInt else {
            fatalError("Invalid hexString")
        }

        let components = (
                R: CGFloat((hex >> 16) & 0xff) / 255,
                G: CGFloat((hex >> 08) & 0xff) / 255,
                B: CGFloat((hex >> 00) & 0xff) / 255
        )

        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}