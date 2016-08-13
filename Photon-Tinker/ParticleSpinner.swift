//
//  ParticleSpinner.swift
//  Particle
//
//  Created by Ido Kleinman on 6/24/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

@objc public class ParticleSpinner : NSObject {
    
    class func show(view : UIView) {
        var hud : MBProgressHUD
        
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .CustomView//.Indeterminate
        hud.animationType = .ZoomIn
        //            hud.labelText = "Loading"
        hud.minShowTime = 0.5
        hud.color = UIColor.clearColor()
        
        // MBProgressHUD 1.0.0 tries:
//        hud.backgroundView.color = UIColor.clearColor()
//        hud.backgroundView.style = .SolidColor
//        hud.bezelView.backgroundColor = UIColor.clearColor()
        
        // prepare spinner view for first time populating of devices into table
        let spinnerView : UIImageView = UIImageView(image: UIImage(named: "particle-mark"))
        spinnerView.frame = CGRectMake(0, 0, 64, 64);
        spinnerView.contentMode = .ScaleToFill
        
        //            spinnerView.image = spinnerView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //            spinnerView.tintColor = UIColor.whiteColor()
        
        //            UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseInOut, animations: {
        //                spinnerView.transform = CGAffineTransformRotate(spinnerView.transform, 2*CGFloat(M_PI))
        //                }, completion: nil)
        
        let rotation = CABasicAnimation(keyPath:"transform.rotation")
        rotation.fromValue = 0
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        rotation.toValue = 2*M_PI;
        rotation.duration = 1;
        rotation.repeatCount = 1000; // Repeat
        spinnerView.layer.addAnimation(rotation,forKey:"Spin")
        
        hud.customView = spinnerView
        
    }
    
    
    class func hide(view : UIView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
    
}