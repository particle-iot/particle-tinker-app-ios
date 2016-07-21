//
//  ParticleUtils.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class ParticleUtils: NSObject {

    static var particleCyanColor = UIColor.color("#00ADEF")!
    static var particleAlmostWhiteColor = UIColor.color("#F7F7F7")!
    static var particleDarkGrayColor = UIColor.color("#333333")!
    static var particleGrayColor = UIColor.color("#777777")!
    static var particleLightGrayColor = UIColor.color("#C7C7C7")!
    static var particlePomegranateColor = UIColor.color("#C0392B")!
    static var particleEmeraldColor = UIColor.color("#2ECC71")!
    static var particleRegularFont = UIFont(name: "Gotham-book", size: 16.0)!
    static var particleBoldFont = UIFont(name: "Gotham-medium", size: 16.0)!

    class func getDeviceTypeAndImage(device : SparkDevice?) -> (deviceType: String, deviceImage: UIImage) {
        
        
        var image : UIImage?
        var text : String?
        
        switch (device!.type)
        {
        case .Core:
            image = UIImage(named: "imgDeviceCore")
            text = "Core"
            
        case .Electron:
            image = UIImage(named: "imgDeviceElectron")
            text = "Electron"
            
        case .Photon:
            image = UIImage(named: "imgDevicePhoton")
            text = "Photon/P0"
            
        case .P1:
            image = UIImage(named: "imgDeviceP1")
            text = "P1"
            
        case .RedBearDuo:
            image = UIImage(named: "imgDeviceRedBearDuo")
            text = "RedBear Duo"
            
        case .Bluz:
            image = UIImage(named: "imgDeviceBluz")
            text = "Bluz"
            
        case .DigistumpOak:
            image = UIImage(named: "imgDeviceDigistumpOak")
            text = "Digistump Oak"
            
        default:
            image = UIImage(named: "imgDeviceUnknown")
            text = "Unknown"
            
        }
        
        
        return (text!, image!)
        
    }

    
    class func shouldDisplayTutorialForViewController(vc : UIViewController) -> Bool {
    
        return true
        /// debug
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let defaultsKeyName = "Tutorial"
        let dictKeyName = String(vc.dynamicType)
        print ("shouldDisplayTutorialForViewController "+dictKeyName)
        
        if let onceDict = prefs.dictionaryForKey(defaultsKeyName) {
            let keyExists = onceDict[dictKeyName] != nil
            if keyExists {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    
    class func setTutorialWasDisplayedForViewController(vc : UIViewController) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let defaultsKeyName = "Tutorial"
        let dictKeyName = String(vc.dynamicType)
        
        if var onceDict = prefs.dictionaryForKey(defaultsKeyName) {
            onceDict[dictKeyName] = true
            prefs.setObject(onceDict, forKey: defaultsKeyName)
        } else {
            prefs.setObject([dictKeyName : true], forKey: defaultsKeyName)
        }
    }
    
    class func resetTutorialWasDisplayed() {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let keyName = "Tutorial"
        prefs.removeObjectForKey(keyName)
        
    }

    
    class func animateOnlineIndicatorImageView(imageView: UIImageView, online: Bool, flashing: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            imageView.image = UIImage(named: "imgCircle")
            //
            
            imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            if flashing {
                imageView.tintColor = UIColor(red: 239.0/255.0, green: 13.0/255.0, blue: 209.0/255.0, alpha: 1.0) // Flashing purple
                imageView.alpha = 1
                UIView.animateWithDuration(0.12, delay: 0, options: [.CurveEaseInOut, .Autoreverse, .Repeat, ], animations: {
                    imageView.alpha = 0
                    }, completion: nil)

            } else if online {
                imageView.tintColor = UIColor(red: 0, green: 173.0/255.0, blue: 239.0/255.0, alpha: 1.0) // ParticleCyan
                
                if imageView.alpha == 1 {
                    //                    print ("1-->0")
                    UIView.animateWithDuration(2.5, delay: 0, options: [.CurveEaseInOut, .Autoreverse, .Repeat, ], animations: {
                        imageView.alpha = 0.15
                        }, completion: nil)
                } else {
                    //                    print ("0-->1")
                    imageView.alpha = 0.15
                    UIView.animateWithDuration(2.5, delay: 0, options: [.CurveEaseInOut, .Autoreverse, .Repeat, ], animations: {
                        imageView.alpha = 1
                        }, completion: nil)
                    
                }
            } else {
                imageView.tintColor = UIColor(white: 0.466, alpha: 1.0) // ParticleGray
            }
        })
    }
    
}
