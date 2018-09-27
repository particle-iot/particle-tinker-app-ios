//
//  ParticleUtils.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 particle. All rights reserved.
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

    class func getDeviceTypeAndImage(_ device : ParticleDevice?) -> (deviceType: String, deviceImage: UIImage) {
        
        
        var image : UIImage?
        var text : String?
        
        if let d = device {
        
            switch (d.type)
            {
            case .core:
                image = UIImage(named: "imgDeviceCore")
                text = "Core"
                
            case .electron:
                image = UIImage(named: "imgDeviceElectron")
                text = "Electron"
                
            case .photon:
                image = UIImage(named: "imgDevicePhoton")
                text = "Photon/P0"
                
            case .P1:
                image = UIImage(named: "imgDeviceP1")
                text = "P1"
     
            case .raspberryPi:
                image = UIImage(named: "imgDeviceRaspberryPi")
                text = "Raspberry Pi"
                
            case .redBearDuo:
                image = UIImage(named: "imgDeviceRedBearDuo")
                text = "RedBear Duo"
                
            case .bluz:
                image = UIImage(named: "imgDeviceBluz")
                text = "Bluz"
                
            case .digistumpOak:
                image = UIImage(named: "imgDeviceDigistumpOak")
                text = "Digistump Oak"

            case .xenon:
                image = UIImage(named: "imgDeviceXenon")
                text = "Xenon"

            case .argon:
                image = UIImage(named: "imgDeviceArgon")
                text = "Argon"

            case .boron:
                image = UIImage(named: "imgDeviceBoron")
                text = "Boron"

            default:
                image = UIImage(named: "imgDeviceUnknown")
                text = "Unknown"
                
            }
            
            
            return (text!, image!)
        } else {
            image = UIImage(named: "imgDeviceUnknown")
            text = "Unknown"
            return (text!, image!)
        }
        
    }


    @objc class func shouldDisplayTutorialForViewController(_ vc : UIViewController) -> Bool {
    
//        return true
        /// debug
        
        let prefs = UserDefaults.standard
        let defaultsKeyName = "Tutorial"
        let dictKeyName = String(describing: type(of: vc))
        
        if let onceDict = prefs.dictionary(forKey: defaultsKeyName) {
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


    @objc class func setTutorialWasDisplayedForViewController(_ vc : UIViewController) {
        
        let prefs = UserDefaults.standard
        let defaultsKeyName = "Tutorial"
        let dictKeyName = String(describing: type(of: vc))
        
        if var onceDict = prefs.dictionary(forKey: defaultsKeyName) {
            onceDict[dictKeyName] = true
            prefs.set(onceDict, forKey: defaultsKeyName)
        } else {
            prefs.set([dictKeyName : true], forKey: defaultsKeyName)
        }
    }
    
    class func resetTutorialWasDisplayed() {
        
        let prefs = UserDefaults.standard
        let keyName = "Tutorial"
        prefs.removeObject(forKey: keyName)
        
    }



    @objc class func animateOnlineIndicatorImageView(_ imageView: UIImageView, online: Bool, flashing: Bool) {
        DispatchQueue.main.async(execute: {
            imageView.image = UIImage(named: "imgCircle")
            //
            
            imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            if flashing {
                imageView.tintColor = UIColor(red: 239.0/255.0, green: 13.0/255.0, blue: 209.0/255.0, alpha: 1.0) // Flashing purple
                imageView.alpha = 1
                UIView.animate(withDuration: 0.12, delay: 0, options: [.autoreverse, .repeat], animations: {
                    imageView.alpha = 0
                    }, completion: nil)

            } else if online {
                imageView.tintColor = UIColor(red: 0, green: 173.0/255.0, blue: 239.0/255.0, alpha: 1.0) // ParticleCyan
                
                if imageView.alpha == 1 {
                    //                    print ("1-->0")
                    UIView.animate(withDuration: 2.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                        imageView.alpha = 0.15
                        }, completion: nil)
                } else {
                    //                    print ("0-->1")
                    imageView.alpha = 0.15
                    UIView.animate(withDuration: 2.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                        imageView.alpha = 1
                        }, completion: nil)
                    
                }
            } else {
                imageView.tintColor = UIColor(white: 0.466, alpha: 1.0) // ParticleGray
                imageView.alpha = 1
                imageView.layer.removeAllAnimations()
            }
        })
    }
    
}
