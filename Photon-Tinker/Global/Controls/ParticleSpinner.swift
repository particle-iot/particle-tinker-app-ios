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
        hud.mode = .customView
        hud.animationType = .zoomIn
        hud.minShowTime = 0.5
        hud.color = UIColor.clear
        
        // prepare spinner view for first time populating of devices into table
        let spinnerView : UIImageView = UIImageView(image: UIImage(named: "ImgParticleSpinner"))
        spinnerView.frame = CGRect(x: 0, y: 0, width: 64, height: 64);
        spinnerView.tintColor = ParticleStyle.ButtonColor
        spinnerView.contentMode = .scaleToFill
        
        let rotation = CABasicAnimation(keyPath:"transform.rotation")
        rotation.isRemovedOnCompletion = false
        rotation.fromValue = 0
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        rotation.toValue = 2*Double.pi;
        rotation.duration = 1;
        rotation.repeatCount = 10000; // Repeat
        spinnerView.layer.add(rotation,forKey:"Spin")
        
        hud.customView = spinnerView
        
    }

    @objc class func hide(_ view : UIView, animated: Bool = true) {
        MBProgressHUD.hide(for: view, animated: animated)
    }
    
}
