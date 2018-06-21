//
//  ParticleSpinner.swift
//  Particle
//
//  Created by Ido Kleinman on 6/24/16.
//  Copyright © 2016 particle. All rights reserved.
//

import Foundation

open class ParticleSpinner : NSObject {
    
    @objc class func show(_ view : UIView) {
        var hud : MBProgressHUD
        
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView//.Indeterminate
        hud.animationType = .zoomIn
        //            hud.labelText = "Loading"
        hud.minShowTime = 0.5
        hud.color = UIColor.clear
        
        // MBProgressHUD 1.0.0 tries:
//        hud.backgroundView.color = UIColor.clearColor()
//        hud.backgroundView.style = .SolidColor
//        hud.bezelView.backgroundColor = UIColor.clearColor()
        
        // prepare spinner view for first time populating of devices into table
        let spinnerView : UIImageView = UIImageView(image: UIImage(named: "particle-mark"))
        spinnerView.frame = CGRect(x: 0, y: 0, width: 64, height: 64);
        spinnerView.contentMode = .scaleToFill
        
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
        spinnerView.layer.add(rotation,forKey:"Spin")
        
        hud.customView = spinnerView
        
    }
    
    
    @objc class func hide(_ view : UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
}
