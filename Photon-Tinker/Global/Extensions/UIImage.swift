//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UIImage {

    func image(withColor newColor: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)

            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            context.setFillColor(newColor.cgColor)
            context.clip(to: rect, mask: cgImage!)
            context.fill(rect)

            let newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        }
        return nil;
    }


    func image(withBackgroundColor bg: UIColor, foregroundColor fg: UIColor, fill: Double) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)

            var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)

            context.setFillColor(bg.cgColor)
            context.fill(rect)

            context.setFillColor(fg.cgColor)
            rect.size.width = rect.width * CGFloat(fill.clamped(to: 0.0 ... 1.0))
            context.fill(rect)


            let newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        }
        return nil;
    }

}
